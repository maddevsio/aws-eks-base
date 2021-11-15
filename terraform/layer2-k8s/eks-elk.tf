locals {
  elk = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "elk")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "elk")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "elk")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "elk")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "elk")].version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "elk")].namespace
  }
  kibana_domain_name = "kibana-${local.domain_suffix}"
  apm_domain_name    = "apm-${local.domain_suffix}"
}

data "template_file" "elk" {
  count = local.elk.enabled ? 1 : 0

  template = file("${path.module}/templates/elk-values.yaml")
  vars = {
    bucket_name             = aws_s3_bucket.elastic_stack[count.index].id
    snapshot_retention_days = var.elk_snapshot_retention_days
    index_retention_days    = var.elk_index_retention_days
    apm_domain_name         = local.apm_domain_name
    kibana_domain_name      = local.kibana_domain_name
    kibana_user             = "kibana-${local.env}"
    kibana_password         = random_string.kibana_password[count.index].result
  }
}

#tfsec:ignore:kubernetes-network-no-public-egress tfsec:ignore:kubernetes-network-no-public-ingress
module "elk_namespace" {
  count = local.elk.enabled ? 1 : 0

  source = "../modules/kubernetes-namespace"
  name   = local.elk.namespace
  network_policies = [
    {
      name         = "default-deny"
      policy_types = ["Ingress", "Egress"]
      pod_selector = {}
    },
    {
      name         = "allow-this-namespace"
      policy_types = ["Ingress"]
      pod_selector = {}
      ingress = {
        from = [
          {
            namespace_selector = {
              match_labels = {
                name = local.elk.namespace
              }
            }
          }
        ]
      }
    },
    {
      name         = "allow-ingress"
      policy_types = ["Ingress"]
      pod_selector = {}
      ingress = {

        from = [
          {
            namespace_selector = {
              match_labels = {
                name = local.ingress_nginx.namespace
              }
            }
          }
        ]
      }
    },
    {
      name         = "allow-apm"
      policy_types = ["Ingress"]
      pod_selector = {
        match_expressions = {
          key      = "app"
          operator = "In"
          values   = ["apm-server"]
        }
      }
      ingress = {
        ports = [
          {
            port     = "8200"
            protocol = "TCP"
          }
        ]
      }
    },
    {
      name         = "allow-egress"
      policy_types = ["Egress"]
      pod_selector = {}
      egress = {
        to = [
          {
            ip_block = {
              cidr = "0.0.0.0/0"
              except = [
                "169.254.169.254/32"
              ]
            }
          }
        ]
      }
    }
  ]
}

module "elastic_tls" {
  count = local.elk.enabled ? 1 : 0

  source                = "../modules/self-signed-certificate"
  name                  = local.name
  common_name           = "elasticsearch-master"
  dns_names             = [local.domain_name, "*.${local.domain_name}", "elasticsearch-master", "elasticsearch-master.${module.elk_namespace[count.index].name}", "kibana", "kibana.${module.elk_namespace[count.index].name}", "kibana-kibana", "kibana-kibana.${module.elk_namespace[count.index].name}", "logstash", "logstash.${module.elk_namespace[count.index].name}"]
  validity_period_hours = 8760
  early_renewal_hours   = 336
}

module "aws_iam_elastic_stack" {
  count = local.elk.enabled ? 1 : 0

  source = "../modules/aws-iam-user-with-policy"
  name   = "${local.name}-${local.elk.name}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads",
          "s3:ListBucketVersions"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.elastic_stack[count.index].id}"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.elastic_stack[count.index].id}/*"
        ]
      }
    ]
  })
}

### ADDITIONAL RESOURCES FOR ELK
resource "kubernetes_secret" "elasticsearch_credentials" {
  count = local.elk.enabled ? 1 : 0

  metadata {
    name      = "elastic-credentials"
    namespace = module.elk_namespace[count.index].name
  }

  data = {
    "username" = "elastic"
    "password" = random_string.elasticsearch_password[count.index].result
  }
}

resource "kubernetes_secret" "elasticsearch_certificates" {
  count = local.elk.enabled ? 1 : 0

  metadata {
    name      = "elastic-certificates"
    namespace = module.elk_namespace[count.index].name
  }

  data = {
    "tls.crt" = module.elastic_tls[count.index].cert_pem
    "tls.key" = module.elastic_tls[count.index].private_key_pem
    "tls.p8"  = module.elastic_tls[count.index].p8
  }
}

resource "kubernetes_secret" "elasticsearch_s3_user_creds" {
  count = local.elk.enabled ? 1 : 0

  metadata {
    name      = "elasticsearch-s3-user-creds"
    namespace = module.elk_namespace[count.index].name
  }

  data = {
    "aws_s3_user_access_key" = module.aws_iam_elastic_stack[count.index].access_key_id
    "aws_s3_user_secret_key" = module.aws_iam_elastic_stack[count.index].access_secret_key
  }
}

resource "random_string" "elasticsearch_password" {
  count = local.elk.enabled ? 1 : 0

  length  = 32
  special = false
  upper   = true
}

resource "kubernetes_secret" "kibana_enc_key" {
  count = local.elk.enabled ? 1 : 0

  metadata {
    name      = "kibana-encryption-key"
    namespace = module.elk_namespace[count.index].name
  }

  data = {
    "encryptionkey" = random_string.kibana_enc_key[count.index].result
  }
}

resource "random_string" "kibana_enc_key" {
  count = local.elk.enabled ? 1 : 0

  length  = 32
  special = false
  upper   = true
}

resource "random_string" "kibana_password" {
  count = local.elk.enabled ? 1 : 0

  length  = 32
  special = false
  upper   = true
}

#tfsec:ignore:aws-s3-enable-versioning tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "elastic_stack" {
  count = local.elk.enabled ? 1 : 0

  bucket        = "${local.name}-elastic-stack"
  acl           = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  tags = {
    Name        = "${local.name}-elastic-stack"
    Environment = local.env
  }
}

resource "aws_s3_bucket_public_access_block" "elastic_stack_public_access_block" {
  count = local.elk.enabled ? 1 : 0

  bucket = aws_s3_bucket.elastic_stack[count.index].id
  # Block new public ACLs and uploading public objects
  block_public_acls = true
  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true
  # Block new public bucket policies
  block_public_policy = true
  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}

resource "helm_release" "elk" {
  count = local.elk.enabled ? 1 : 0

  name        = local.elk.name
  chart       = local.elk.chart
  repository  = local.elk.repository
  version     = local.elk.chart_version
  namespace   = module.elk_namespace[count.index].name
  timeout     = "900"
  max_history = var.helm_release_history_size

  values = [
    data.template_file.elk[count.index].rendered
  ]

}

output "kibana_domain_name" {
  value       = local.elk.enabled ? local.kibana_domain_name : null
  description = "Kibana dashboards address"
}

output "apm_domain_name" {
  value       = local.elk.enabled ? local.apm_domain_name : null
  description = "APM domain name"
}

output "elasticsearch_elastic_password" {
  value       = local.elk.enabled ? random_string.elasticsearch_password[0].result : null
  sensitive   = true
  description = "Password of the superuser 'elastic'"
}

output "elastic_stack_bucket_name" {
  value       = local.elk.enabled ? aws_s3_bucket.elastic_stack[0].id : null
  description = "Name of the bucket for ELKS snapshots"
}
