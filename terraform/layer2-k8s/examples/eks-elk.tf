locals {
  kibana_domain_name        = "kibana-${local.domain_suffix}"
  apm_domain_name           = "apm-${local.domain_suffix}"
  elastic_stack_bucket_name = data.terraform_remote_state.layer1-aws.outputs.elastic_stack_bucket_name
}

data "template_file" "elk" {
  template = file("${path.module}/templates/elk-values.yaml")

  vars = {
    bucket_name             = local.elastic_stack_bucket_name
    storage_class_name      = kubernetes_storage_class.elk.id
    snapshot_retention_days = var.elk_snapshot_retention_days
    index_retention_days    = var.elk_index_retention_days
    apm_domain_name         = local.apm_domain_name
    kibana_domain_name      = local.kibana_domain_name
    kibana_user             = "kibana-${local.env}"
    kibana_password         = random_string.kibana_password.result
    kibana_base64_creds     = base64encode("kibana-${local.env}:${random_string.kibana_password.result}")
  }
}

resource "helm_release" "elk" {
  name        = "elk"
  chart       = "../../helm-charts/elk"
  namespace   = kubernetes_namespace.elk.id
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    data.template_file.elk.rendered
  ]
}

### ADDITIONAL RESOURCES FOR ELK

resource "kubernetes_storage_class" "elk" {
  metadata {
    name = "elk"
  }
  storage_provisioner    = "kubernetes.io/aws-ebs"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true
  parameters = {
    type      = "gp2"
    encrypted = true
    fsType    = "ext4"
  }
}

module "elastic_tls" {
  source = "../modules/self-signed-certificate"

  name                  = local.name
  common_name           = "elasticsearch-master"
  dns_names             = [local.domain_name, "*.${local.domain_name}", "elasticsearch-master", "elasticsearch-master.${kubernetes_namespace.elk.id}", "kibana", "kibana.${kubernetes_namespace.elk.id}", "kibana-kibana", "kibana-kibana.${kubernetes_namespace.elk.id}", "logstash", "logstash.${kubernetes_namespace.elk.id}"]
  validity_period_hours = 8760
  early_renewal_hours   = 336
}

resource "kubernetes_secret" "elasticsearch_credentials" {
  metadata {
    name      = "elastic-credentials"
    namespace = kubernetes_namespace.elk.id
  }

  data = {
    "username" = "elastic"
    "password" = random_string.elasticsearch_password.result
  }
}

resource "kubernetes_secret" "elasticsearch_certificates" {
  metadata {
    name      = "elastic-certificates"
    namespace = kubernetes_namespace.elk.id
  }

  data = {
    "tls.crt" = module.elastic_tls.cert_pem
    "tls.key" = module.elastic_tls.private_key_pem
    "tls.p8"  = module.elastic_tls.p8
  }
}

resource "kubernetes_secret" "elasticsearch_s3_user_creds" {
  metadata {
    name      = "elasticsearch-s3-user-creds"
    namespace = kubernetes_namespace.elk.id
  }

  data = {
    "aws_s3_user_access_key" = module.aws_iam_elastic_stack.access_key_id
    "aws_s3_user_secret_key" = module.aws_iam_elastic_stack.access_secret_key
  }
}

resource "random_string" "elasticsearch_password" {
  length  = 32
  special = false
  upper   = true
}

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

module "aws_iam_elastic_stack" {
  source = "../modules/aws-iam-s3"

  name              = "${local.name}-elk"
  region            = local.region
  bucket_names      = [local.elastic_stack_bucket_name]
  oidc_provider_arn = local.eks_oidc_provider_arn
  create_user       = true
}

output "kibana_domain_name" {
  value       = local.kibana_domain_name
  description = "Kibana dashboards address"
}

output "apm_domain_name" {
  value       = local.apm_domain_name
  description = ""
}

output "elasticsearch_elastic_password" {
  value       = random_string.elasticsearch_password.result
  sensitive   = true
  description = "Password of the superuser 'elastic'"
}
