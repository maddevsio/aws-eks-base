locals {
  cert_manager_cluster_issuer = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "cert-manager-cluster-issuer")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "cert-manager-cluster-issuer")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "cert-manager-cluster-issuer")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "cert-manager-cluster-issuer")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "cert-manager-cluster-issuer")].version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "cert-manager-cluster-issuer")].namespace
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
  count = local.cert_manager_cluster_issuer.enabled ? 1 : 0

  name        = local.cert_manager_cluster_issuer.name
  chart       = local.cert_manager_cluster_issuer.chart
  repository  = local.cert_manager_cluster_issuer.repository
  version     = local.cert_manager_cluster_issuer_version
  namespace   = local.cert_manager_cluster_issuer.namespace
  max_history = var.helm_release_history_size

  values = [
    data.template_file.cluster_issuer.rendered,
  ]

  # This dep needs for correct apply
  depends_on = [helm_release.cert_manager]
}
