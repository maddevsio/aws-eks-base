locals {
  cert_mananger_certificate = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "cert-mananger-certificate")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "cert-mananger-certificate")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "cert-mananger-certificate")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "cert-mananger-certificate")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "cert-mananger-certificate")].version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "cert-mananger-certificate")].namespace
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
  count = local.cert_mananger_certificate.enabled ? 1 : 0

  name        = local.cert_mananger_certificate.name
  chart       = local.cert_mananger_certificate.chart
  repository  = local.cert_mananger_certificate.repository
  version     = local.cert_mananger_certificate_version
  namespace   = local.cert_mananger_certificate.namespace
  max_history = var.helm_release_history_size

  values = [
    data.template_file.certificate.rendered,
  ]

  # This dep needs for correct apply
  depends_on = [helm_release.cert_manager, helm_release.cluster_issuer]
}
