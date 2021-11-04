locals {
  cert-manager = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "cert-manager")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "cert-manager")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "cert-manager")], "version", null)
  }
}

data "template_file" "cert_manager" {
  template = file("${path.module}/templates/cert-manager-values.yaml")

  vars = {
    role_arn = module.aws_iam_cert_manager.role_arn
  }
}

resource "helm_release" "cert_manager" {
  name        = "cert-manager"
  chart       = local.cert-manager.chart
  repository  = local.cert-manager.repository
  version     = local.cert-manager.chart_version
  namespace   = module.certmanager_namespace.name
  wait        = true
  max_history = var.helm_release_history_size

  values = [
    data.template_file.cert_manager.rendered,
  ]
}

module "certmanager_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "certmanager"
}

#tfsec:ignore:aws-iam-no-policy-wildcards
module "aws_iam_cert_manager" {
  source = "../modules/aws-iam-eks-trusted"

  name              = "${local.name}-certmanager"
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
