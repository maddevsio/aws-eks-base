data "template_file" "apm-server" {
  template = file("${path.module}/templates/elastic/apm-values.yaml")

  vars = {
    domain_name = local.apm_domain_name
  }
}

resource "helm_release" "apm-server" {
  name        = "apm-server"
  chart       = "apm-server"
  repository  = local.helm_repo_elastic
  version     = var.elk_version
  namespace   = kubernetes_namespace.elk.id
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    data.template_file.apm.rendered,
  ]

  # This dep needs for correct apply
  depends_on = [helm_release.elasticsearch, kubernetes_namespace.elk]
}
