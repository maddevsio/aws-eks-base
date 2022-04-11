locals {
  gitlab_runner = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "gitlab-runner")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "gitlab-runner")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "gitlab-runner")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "gitlab-runner")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "gitlab-runner")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "gitlab-runner")].namespace
  }
  gitlab_runner_registration_token = lookup(jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string), "gitlab_runner_registration_token", "")
  gitlab_runner_values             = <<VALUES
rbac:
  create: true
  clusterWideAccess: true
  serviceAccountAnnotations:
    eks.amazonaws.com/role-arn: ${local.gitlab_runner.enabled ? module.aws_iam_gitlab_runner[0].role_arn : ""}

runnerRegistrationToken: "${local.gitlab_runner_registration_token}"
gitlabUrl: "https://gitlab.com/"
concurrent: 4
checkInterval: 30

runners:
  tags: "eks-k8s"
  runUntagged: false

  config: |
    [[runners]]
      executor = "kubernetes"
      request_concurrency = 1
      [runners.kubernetes]
        namespace = "{{.Release.Namespace}}"
        image = "public.ecr.aws/ubuntu/ubuntu:20.04"
        privileged = true
        cpu_request = "250m"
        cpu_limit = "950m"
        memory_request = "512Mi"
        memory_limit = "2500Mi"
        helper_cpu_request = "250m"
        helper_cpu_limit = "950m"
        helper_memory_request = "256Mi"
        helper_memory_limit = "512Mi"
        service_cpu_request = "250m"
        service_cpu_limit = "950m"
        service_memory_request = "256Mi"
        service_memory_limit = "512Mi"
        [runners.kubernetes.node_selector]
          nodegroup = "ci"
        [runners.kubernetes.node_tolerations]
          "nodegroup=ci" = "NoSchedule"
        [runners.kubernetes.volumes]
          [[runners.kubernetes.volumes.empty_dir]]
            name = "docker-certs"
            mount_path = "/certs/client"
            medium = "Memory"
      [runners.cache]
        Type = "s3"
        Path = "gitlab_runner"
        Shared = false
        [runners.cache.s3]
          ServerAddress = "s3.amazonaws.com"
          BucketName = "${local.gitlab_runner.enabled ? aws_s3_bucket.gitlab_runner_cache[0].id : "bucket_name"}"
          BucketLocation = "${local.region}"
          Insecure = false
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
