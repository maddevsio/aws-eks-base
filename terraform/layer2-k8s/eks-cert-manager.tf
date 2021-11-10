locals {
  cert_manager = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "cert-manager")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "cert-manager")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "cert-manager")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "cert-manager")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "cert-manager")].version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "cert-manager")].namespace
  }
}

data "template_file" "cert_manager" {
  template = file("${path.module}/templates/cert-manager-values.yaml")

  vars = {
    role_arn = local.cert_manager.enabled ? module.aws_iam_cert_manager[0].role_arn : ""
  }
}

#tfsec:ignore:kubernetes-network-no-public-egress tfsec:ignore:kubernetes-network-no-public-ingress
module "certmanager_namespace" {
  count = local.cert_manager.enabled ? 1 : 0

  source = "../modules/kubernetes-namespace"
  name   = local.cert_manager.namespace
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
                name = local.cert_manager.namespace
              }
            }
          }
        ]
      }
    },
    {
      name         = "allow-control-plane"
      policy_types = ["Ingress"]
      pod_selector = {
        match_expressions = {
          key      = "app.kubernetes.io/name"
          operator = "In"
          values   = ["webhook"]
        }
      }
      ingress = {
        ports = [
          {
            port     = "10250"
            protocol = "TCP"
          }
        ]
        from = [
          {
            ip_block = {
              cidr = "0.0.0.0/0"
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
module "aws_iam_cert_manager" {
  count = local.cert_manager.enabled ? 1 : 0

  source            = "../modules/aws-iam-eks-trusted"
  name              = "${local.name}-${local.cert_manager.name}"
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

resource "helm_release" "cert_manager" {
  count = local.cert_manager.enabled ? 1 : 0

  name        = local.cert_manager.name
  chart       = local.cert_manager.chart
  repository  = local.cert_manager.repository
  version     = local.cert_manager.chart_version
  namespace   = module.certmanager_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    data.template_file.cert_manager.rendered,
  ]

}
