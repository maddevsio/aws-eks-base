locals {
  external_dns = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "external-dns")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "external-dns")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "external-dns")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "external-dns")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "external-dns")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "external-dns")].namespace
  }
  external_dns_values = <<VALUES
rbac:
  create: true

serviceAccount:
  create: true
  name: "external-dns"
  annotations:
    "eks.amazonaws.com/role-arn": ${local.external_dns.enabled ? module.aws_iam_external_dns[0].role_arn : ""}

provider: aws
domainFilters: [${local.domain_name}]
extraArgs:
  - --aws-zone-type=public
  - --aws-batch-change-size=1000

serviceMonitor:
  enabled: false

sources:
  - service
  - ingress
#  - istio-virtualservice
VALUES
}

#tfsec:ignore:kubernetes-network-no-public-egress tfsec:ignore:kubernetes-network-no-public-ingress
module "external_dns_namespace" {
  count = local.external_dns.enabled ? 1 : 0

  source = "../modules/kubernetes-namespace"
  name   = local.external_dns.namespace
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
                name = local.external_dns.namespace
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
module "aws_iam_external_dns" {
  count = local.external_dns.enabled ? 1 : 0

  source            = "../modules/aws-iam-eks-trusted"
  name              = "${local.name}-${local.external_dns.name}"
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "route53:GetChange",
        "Resource" : "arn:aws:route53:::change/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZones"
        ],
        "Resource" : ["*"]
      },
      {
        "Effect" : "Allow",
        "Action" : "route53:ListHostedZonesByName",
        "Resource" : "*"
      }
    ]
  })
}

resource "helm_release" "external_dns" {
  count = local.external_dns.enabled ? 1 : 0

  name        = local.external_dns.name
  chart       = local.external_dns.chart
  repository  = local.external_dns.repository
  version     = local.external_dns.chart_version
  namespace   = module.external_dns_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    local.external_dns_values
  ]

}
