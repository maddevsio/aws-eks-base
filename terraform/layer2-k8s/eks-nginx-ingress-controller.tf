data "template_file" "nginx_ingress" {
  template = "${file("${path.module}/templates/nginx-ingress-values.yaml")}"

  vars = {
    hostname           = "${local.domain_name}"
    ssl_cert           = local.ssl_certificate_arn
    proxy_real_ip_cidr = local.vpc_cidr
    namespace          = kubernetes_namespace.ing.id
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  chart      = "nginx-ingress"
  repository = local.helm_repo_stable
  namespace  = kubernetes_namespace.ing.id
  version    = var.nginx_ingress_controller_version
  wait       = false

  values = [
    "${data.template_file.nginx_ingress.rendered}",
  ]
}
