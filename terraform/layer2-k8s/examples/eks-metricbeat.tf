data "template_file" "metricbeat" {
  template = file("${path.module}/templates/elastic/metricbeat-values.yaml")
}

resource "helm_release" "metricbeat" {
  name        = "metricbeat"
  chart       = "metricbeat"
  repository  = local.helm_repo_elastic
  version     = var.elk_version
  namespace   = kubernetes_namespace.elk.id
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    data.template_file.metricbeat.rendered
  ]

  # This dep needs for correct apply
  depends_on = [helm_release.elasticsearch, kubernetes_namespace.elk]
}
