locals {
  gitlab-runner = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "gitlab-runner")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "gitlab-runner")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "gitlab-runner")], "version", null)
  }
  gitlab_runner_template = templatefile("${path.module}/templates/gitlab-runner-values.yaml",
    {
      registration_token = local.gitlab_registration_token
      namespace          = module.ci_namespace.name
      role_arn           = module.aws_iam_gitlab_runner.role_arn
      bucket_name        = aws_s3_bucket.gitlab_runner_cache.id
      region             = local.region
  })
}

module "gitlab_runner_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "gitlab-runner"
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
                name = "gitlab-runner"
              }
            }
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

resource "aws_s3_bucket" "gitlab_runner_cache" {
  bucket = "${local.name}-gitlab-runner-cache"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    id      = "gitlab-runner-cache-lifecycle-rule"
    enabled = true

    tags = {
      "rule" = "gitlab-runner-cache-lifecycle-rule"
    }

    expiration {
      days = 120
    }
  }

  tags = {
    Name        = "${local.name}-gitlab-runner-cache"
    Environment = local.env
  }
}

resource "aws_s3_bucket_public_access_block" "gitlab_runner_cache_public_access_block" {
  bucket = aws_s3_bucket.gitlab_runner_cache.id
  # Block new public ACLs and uploading public objects
  block_public_acls = true
  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true
  # Block new public bucket policies
  block_public_policy = true
  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}

module "aws_iam_gitlab_runner" {
  source = "../modules/aws-iam-eks-trusted"

  name              = "${local.name}-ci"
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings",
          "ecr:DescribeImages"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:*"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.gitlab_runner_cache.id}",
          "arn:aws:s3:::${aws_s3_bucket.gitlab_runner_cache.id}/*"
        ]
      }
    ]
  })
}

resource "helm_release" "gitlab_runner" {
  name        = "gitlab-runner"
  chart       = local.gitlab-runner.chart
  repository  = local.gitlab-runner.repository
  version     = local.gitlab-runner.chart_version
  namespace   = module.gitlab_runner_namespace.name
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    local.gitlab_runner_template
  ]

}

output "gitlab_runner_cache_bucket_name" {
  value       = aws_s3_bucket.gitlab_runner_cache.id
  description = "Name of the s3 bucket for gitlab-runner cache"
}
