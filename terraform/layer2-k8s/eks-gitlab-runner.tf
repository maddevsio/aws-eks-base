locals {
  gitlab_runner = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "gitlab-runner")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "gitlab-runner")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "gitlab-runner")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "gitlab-runner")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "gitlab-runner")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "gitlab-runner")].namespace
  }
  gitlab_runner_values = <<VALUES
gitlabUrl: "https://gitlab.com/"
runnerRegistrationToken: "${local.gitlab_registration_token}"
concurrent: 4
checkInterval: 30

rbac:
  create: true
  clusterWideAccess: true
  serviceAccountAnnotations:
    eks.amazonaws.com/role-arn: ${local.gitlab_runner.enabled ? module.aws_iam_gitlab_runner[0].role_arn : ""}

runners:
  image: ubuntu:18.04
  privileged: true
  namespace: ${local.gitlab_runner.enabled ? module.gitlab_runner_namespace[0].name : "default"}
  tags: "eks-k8s"
  runUntagged: false
  nodeTolerations:
  - key: "nodegroup"
    operator: "Equal"
    value: "ci"
    effect: "NoSchedule"
  nodeSelector:
    nodegroup: ci
  cache:
    cacheType: s3
    cachePath: "gitlab_runner"
    cacheShared: false
    s3ServerAddress: s3.amazonaws.com
    s3BucketName: ${local.gitlab_runner.enabled ? aws_s3_bucket.gitlab_runner_cache[0].id : "bucket_name"}
    s3BucketLocation: ${local.region}
    s3CacheInsecure: false

  builds:
    cpuLimit: 950m
    memoryLimit: 2500Mi
    cpuRequests: 250m
    memoryRequests: 512Mi
  services:
    cpuLimit: 950m
    memoryLimit: 2500Mi
    cpuRequests: 250m
    memoryRequests: 128Mi
  helpers:
    cpuLimit: 950m
    memoryLimit: 2500Mi
    cpuRequests: 250m
    memoryRequests: 512Mi
VALUES
}

#tfsec:ignore:kubernetes-network-no-public-egress tfsec:ignore:kubernetes-network-no-public-ingress
module "gitlab_runner_namespace" {
  count = local.gitlab_runner.enabled ? 1 : 0

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

#tfsec:ignore:aws-s3-enable-versioning tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "gitlab_runner_cache" {
  count = local.gitlab_runner.enabled ? 1 : 0

  bucket        = "${local.name}-gitlab-runner-cache"
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
    Name        = "${local.name}-gitlab-runner-cache"
    Environment = local.env
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
}

resource "aws_s3_bucket_public_access_block" "gitlab_runner_cache_public_access_block" {
  count = local.gitlab_runner.enabled ? 1 : 0

  bucket = aws_s3_bucket.gitlab_runner_cache[count.index].id
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
  count = local.gitlab_runner.enabled ? 1 : 0

  source            = "../modules/aws-iam-eks-trusted"
  name              = "${local.name}-${local.gitlab_runner.name}"
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
          "arn:aws:s3:::${aws_s3_bucket.gitlab_runner_cache[count.index].id}",
          "arn:aws:s3:::${aws_s3_bucket.gitlab_runner_cache[count.index].id}/*"
        ]
      }
    ]
  })
}

resource "helm_release" "gitlab_runner" {
  count = local.gitlab_runner.enabled ? 1 : 0

  name        = local.gitlab_runner.name
  chart       = local.gitlab_runner.chart
  repository  = local.gitlab_runner.repository
  version     = local.gitlab_runner.chart_version
  namespace   = module.gitlab_runner_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    local.gitlab_runner_values
  ]

}

output "gitlab_runner_cache_bucket_name" {
  value       = local.gitlab_runner.enabled ? aws_s3_bucket.gitlab_runner_cache[0].id : null
  description = "Name of the s3 bucket for gitlab-runner cache"
}
