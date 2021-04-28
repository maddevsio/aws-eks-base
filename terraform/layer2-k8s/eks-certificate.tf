data "template_file" "certificate" {
  template = file("${path.module}/templates/certificate-values.yaml")

  vars = {
    domain_name = "*.${local.domain_name}"
    common_name = local.domain_name
  }
}

resource "helm_release" "certificate" {
  name        = "certificate"
  chart       = "../../helm-charts/certificate"
  namespace   = module.ing_namespace.name
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    data.template_file.certificate.rendered,
  ]

  # This dep needs for correct apply
  depends_on = [helm_release.cert_manager, helm_release.cluster_issuer]
}
