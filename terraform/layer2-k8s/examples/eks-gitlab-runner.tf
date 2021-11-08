locals {
  gitlab-runner = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "gitlab-runner")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "gitlab-runner")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "gitlab-runner")], "version", null)
  }
  gitlab_runner_cache_bucket_name = data.terraform_remote_state.layer1-aws.outputs.gitlab_runner_cache_bucket_name

  gitlab_runner_template = templatefile("${path.module}/templates/gitlab-runner-values.tmpl",
    {
      registration_token = local.gitlab_registration_token
      namespace          = module.ci_namespace.name
      role_arn           = module.aws_iam_gitlab_runner.role_arn
      bucket_name        = local.gitlab_runner_cache_bucket_name
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
          "arn:aws:s3:::${local.gitlab_runner_cache_bucket_name}",
          "arn:aws:s3:::${local.gitlab_runner_cache_bucket_name}/*"
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
