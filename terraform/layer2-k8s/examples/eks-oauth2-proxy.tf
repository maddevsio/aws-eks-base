resource "random_string" "kibana_ouath2_secret_cookie" {
  length  = 32
  special = false
  upper   = true
}

resource "kubernetes_secret" "kibana_oauth2_secrets" {
  metadata {
    name      = "kibana-oauth2-secrets"
    namespace = kubernetes_namespace.elk.id
  }

  data = {
    "cookie-secret" = random_string.kibana_ouath2_secret_cookie.result
    "client-secret" = local.kibana_gitlab_client_secret
    "client-id"     = local.kibana_gitlab_client_id
  }
}

data "template_file" "oauth2_proxy" {
  template = file("${path.module}/templates/oauth2-proxy-values.yaml")

  vars = {
    domain_name  = local.kibana_domain_name
    gitlab_group = var.kibana_gitlab_group
  }
}

resource "helm_release" "oauth2_proxy" {
  name       = "oauth2-proxy"
  chart      = "oauth2-proxy"
  repository = local.helm_repo_stable
  namespace  = kubernetes_namespace.elk.id
  version    = var.oauth2_proxy_version
  wait       = false

  values = [
    "${data.template_file.oauth2_proxy.rendered}",
  ]
}

