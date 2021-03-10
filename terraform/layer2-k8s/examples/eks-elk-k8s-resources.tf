locals {
  kibana_domain_name = "kibana-${local.domain_suffix}"
  apm_domain_name    = "apm-${local.domain_suffix}"
}

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

module "aws_iam_elastic_stack" {
  source = "../modules/aws-iam-s3"

  name              = "${local.name}-elk"
  region            = local.region
  bucket_names      = [local.elastic_stack_bucket_name]
  oidc_provider_arn = local.eks_oidc_provider_arn
  create_user       = true
}
