resource "kubernetes_secret" "kibana_enc_key" {
  metadata {
    name      = "kibana-encryption-key"
    namespace = kubernetes_namespace.elk.id
  }

  data = {
    "encryptionkey" = random_string.kibana_enc_key.result
  }
}

resource "random_string" "kibana_enc_key" {
  length  = 32
  special = false
  upper   = true
}

resource "random_string" "dev_user_password" {
  length  = 32
  special = false
  upper   = true
}

data "template_file" "kibana" {
  template = file("${path.module}/templates/elk/kibana-values.yaml")

  vars = {
    domain_name             = local.kibana_domain_name
    bucket_name             = local.elastic_stack_bucket_name
    dev_user_password       = random_string.dev_user_password.result
    dev_user_base64_creds   = base64encode("teacherly:${random_string.dev_user_password.result}")
    snapshot_retention_days = var.elk_snapshot_retention_days
    index_retention_days    = var.elk_index_retention_days
  }
}

resource "helm_release" "kibana" {
  name       = "kibana"
  chart      = "kibana"
  repository = local.helm_repo_elastic
  version    = var.elk_version
  namespace  = kubernetes_namespace.elk.id
  wait       = false

  values = [
    "${data.template_file.kibana.rendered}",
  ]

  # This dep needs for correct apply
  depends_on = [helm_release.elasticsearch, kubernetes_namespace.elk, kubernetes_secret.kibana_enc_key]
}
