locals {
  external_secrets = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "external-secrets")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "external-secrets")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "external-secrets")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "external-secrets")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "external-secrets")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "external-secrets")].namespace
  }
  external_secrets_values = <<VALUES
# Environment variables to set on deployment pod
env:
  AWS_REGION: ${local.region}
  AWS_DEFAULT_REGION: ${local.region}
  POLLER_INTERVAL_MILLISECONDS: 30000
  # trace, debug, info, warn, error, fatal
  LOG_LEVEL: warn
  LOG_MESSAGE_KEY: 'msg'
  METRICS_PORT: 3001

serviceAccount:
  annotations:
    "eks.amazonaws.com/role-arn": ${local.external_secrets.enabled ? module.aws_iam_external_secrets[0].role_arn : ""}

securityContext:
  # Required for use of IRSA, see https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts-technical-overview.html
  fsGroup: 1000
VALUES
}

#tfsec:ignore:kubernetes-network-no-public-egress tfsec:ignore:kubernetes-network-no-public-ingress
module "external_secrets_namespace" {
  count = local.external_secrets.enabled ? 1 : 0

  source = "../modules/kubernetes-namespace"
  name   = local.external_secrets.namespace
  network_policies = [
    {
      name         = "default-deny"
      policy_types = ["Ingress"]
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
                name = local.external_secrets.namespace
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


#tfsec:ignore:aws-iam-no-policy-wildcards
module "aws_iam_external_secrets" {
  count = local.external_secrets.enabled ? 1 : 0

  source            = "../modules/aws-iam-eks-trusted"
  name              = "${local.name}-${local.external_secrets.name}"
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameter",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "helm_release" "external_secrets" {
  count = local.external_secrets.enabled ? 1 : 0

  name        = local.external_secrets.name
  chart       = local.external_secrets.chart
  repository  = local.external_secrets.repository
  version     = local.external_secrets.chart_version
  namespace   = module.external_secrets_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    local.external_secrets_values
  ]

}
