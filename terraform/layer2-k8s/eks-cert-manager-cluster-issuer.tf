locals {
  cert-manager-cluster-issuer = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "cert-manager-cluster-issuer")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "cert-manager-cluster-issuer")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "cert-manager-cluster-issuer")], "version", null)
  }
}

data "template_file" "cluster_issuer" {
  template = file("${path.module}/templates/cluster-issuer-values.yaml")

  vars = {
    region  = local.region
    zone    = local.domain_name
    zone_id = local.zone_id
  }
}

resource "helm_release" "cluster_issuer" {
  name        = "cluster-issuer"
  chart       = local.cert-manager-cluster-issuer.chart
  repository  = local.cert-manager-cluster-issuer.repository
  version     = local.cert-manager-cluster-issuer.chart_version
  namespace   = module.certmanager_namespace.name
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    data.template_file.cluster_issuer.rendered,
  ]

  # This dep needs for correct apply
  depends_on = [helm_release.cert_manager]
}
