data "template_file" "filebeat" {
  template = file("${path.module}/templates/elastic/filebeat-values.yaml")
}

resource "helm_release" "filebeat" {
  name        = "filebeat"
  chart       = "filebeat"
  repository  = local.helm_repo_elastic
  version     = var.elk_version
  namespace   = kubernetes_namespace.elk.id
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    data.template_file.filebeat.rendered
  ]

  # This dep needs for correct apply
  depends_on = [helm_release.elasticsearch, kubernetes_namespace.elk]
}
