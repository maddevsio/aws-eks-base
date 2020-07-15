data "template_file" "apm" {
  template = file("${path.module}/templates/elk/apm-values.yaml")

  vars = {
    domain_name = local.apm_domain_name
    bucket_name = local.elastic_stack_bucket_name
  }
}

resource "helm_release" "apm" {
  name       = "apm-server"
  chart      = "apm-server"
  repository = local.helm_repo_elastic
  version    = var.elk_version
  namespace  = kubernetes_namespace.elk.id
  wait       = false

  values = [
    "${data.template_file.apm.rendered}",
  ]

  # This dep needs for correct apply
  depends_on = [helm_release.elasticsearch, kubernetes_namespace.elk]
}
