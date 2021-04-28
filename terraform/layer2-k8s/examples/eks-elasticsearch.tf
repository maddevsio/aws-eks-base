data "template_file" "elasticsearch" {
  template = file("${path.module}/templates/elastic/elasticsearch-values.yaml")

  vars = {
    iam_role_arn       = module.aws_iam_elastic_stack.role_arn
    storage_class_name = kubernetes_storage_class.elk.id
  }
}

resource "helm_release" "elasticsearch" {
  name        = "elasticsearch"
  chart       = "elasticsearch"
  repository  = local.helm_repo_elastic
  version     = var.elk_version
  namespace   = kubernetes_namespace.elk.id
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    data.template_file.elasticsearch.rendered
  ]

  # This dep needs for correct apply
  depends_on = [kubernetes_storage_class.elk, data.template_file.elasticsearch, kubernetes_namespace.elk, kubernetes_secret.elasticsearch_credentials, kubernetes_secret.elasticsearch_certificates]
}
