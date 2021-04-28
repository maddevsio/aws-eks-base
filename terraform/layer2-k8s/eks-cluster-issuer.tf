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
  chart       = "../../helm-charts/cluster-issuer"
  namespace   = kubernetes_namespace.certmanager.id
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    data.template_file.cluster_issuer.rendered,
  ]

  # This dep needs for correct apply
  depends_on = [helm_release.cert_manager, kubernetes_namespace.certmanager]
}
