locals {
  github_runner = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "github-runner")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "github-runner")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "github-runner")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "github-runner")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "github-runner")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "github-runner")].namespace
  }
  github_runner_registration_token = lookup(jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string), "github_runner_registration_token", "")
  github_runner_values             = <<VALUES
authSecret:
  annotations:
    github_token: ${local.github_runner_registration_token}
serviceAccount:
  name: dev-runner-sa
  annotations:
    eks.amazonaws.com/role-arn: ${local.github_runner.enabled ? module.aws_iam_github_runner[0].role_arn : ""}
   
VALUES
}

resource "kubernetes_service_account" "dev_runner_sa" {
  metadata {
    name      = "dev-runner-sa"
    namespace = "dev"
  }
}

resource "kubernetes_role" "dev_runner_role" {
  metadata {
    name      = "dev-runner-role"
    namespace = "dev"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps"]
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
  }
}

resource "kubernetes_role_binding" "dev_runner_rolebinding" {
  metadata {
    name      = "dev-runner-rolebinding"
    namespace = "dev"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dev_runner_sa.metadata[0].name
    namespace = "dev"
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.dev_runner_role.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}

module "github_runner_namespace" {
  count = local.github_runner.enabled ? 1 : 0

  source = "../eks-kubernetes-namespace"
  name   = "github-runner"
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
                name = "github-runner"
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

# resource "kubernetes_manifest" "runner_deployment" {
#   depends_on = [helm_release.github_runner]
#   manifest = {
#     apiVersion = "actions.summerwind.dev/v1alpha1"
#     kind       = "RunnerDeployment"
#     metadata = {
#       name      = "dev-runner"
#       namespace = "dev"
#     }
#     spec = {
#       replicas = 1
#       template = {
#         spec = {
#           nodeSelector = {
#             "eks.amazonaws.com/capacity-type" = "SPOT"
#           }
#         }
#       }
#     }
#   }
# }

module "aws_iam_github_runner" {
  count = local.github_runner.enabled ? 1 : 0

  source            = "../aws-iam-eks-trusted"
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
      }
    ]
  })
}

resource "helm_release" "github_runner" {
  count = local.github_runner.enabled ? 1 : 0

  name        = local.github_runner.name
  chart       = local.github_runner.chart
  repository  = local.github_runner.repository
  version     = local.github_runner.chart_version
  namespace   = module.github_runner_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    local.github_runner_values
  ]
}
