locals {
  cert-mananger-certificate = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "cert-mananger-certificate")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "cert-mananger-certificate")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "cert-mananger-certificate")], "version", null)
  }
}

data "template_file" "certificate" {
  template = file("${path.module}/templates/certificate-values.yaml")

  vars = {
    domain_name = "*.${local.domain_name}"
    common_name = local.domain_name
  }
}

resource "helm_release" "certificate" {
  name        = "certificate"
  chart       = local.cert-mananger-certificate.chart
  repository  = local.cert-mananger-certificate.repository
  version     = local.cert-mananger-certificate.chart_version
  namespace   = module.ingress_nginx_namespace.name
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    data.template_file.certificate.rendered,
  ]

  # This dep needs for correct apply
  depends_on = [helm_release.cert_manager, helm_release.cluster_issuer]
}
