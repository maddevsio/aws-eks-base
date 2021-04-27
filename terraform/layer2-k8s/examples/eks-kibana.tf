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

resource "random_string" "kibana_password" {
  length  = 32
  special = false
  upper   = true
}

data "template_file" "kibana" {
  template = file("${path.module}/templates/elastic/kibana-values.yaml")

  vars = {
    domain_name             = local.kibana_domain_name
    bucket_name             = local.elastic_stack_bucket_name
    kibana_user             = "kibana-${local.env}"
    kibana_password         = random_string.kibana_password.result
    kibana_base64_creds     = base64encode("kibana-${local.env}:${random_string.kibana_password.result}")
    snapshot_retention_days = var.elk_snapshot_retention_days
    index_retention_days    = var.elk_index_retention_days
  }
}

resource "helm_release" "kibana" {
  name        = "kibana"
  chart       = "kibana"
  repository  = local.helm_repo_elastic
  version     = var.elk_version
  namespace   = kubernetes_namespace.elk.id
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    data.template_file.kibana.rendered
  ]

  # This dep needs for correct apply
  depends_on = [helm_release.elasticsearch, kubernetes_namespace.elk, kubernetes_secret.kibana_enc_key]
}
