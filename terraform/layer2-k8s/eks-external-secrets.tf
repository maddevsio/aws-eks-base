locals {
  external-secrets = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "external-secrets")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "external-secrets")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "external-secrets")], "version", null)
  }
  reloader = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "reloader")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "reloader")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "reloader")], "version", null)
  }
}

data "template_file" "external_secrets" {
  template = file("${path.module}/templates/external-secrets-values.yaml")

  vars = {
    role_arn = module.aws_iam_external_secrets.role_arn
    region   = local.region
  }
}

resource "helm_release" "external_secrets" {
  name        = "external-secrets"
  chart       = local.external-secrets.chart
  repository  = local.external-secrets.repository
  version     = local.external-secrets.chart_version
  namespace   = module.sys_namespace.name
  max_history = var.helm_release_history_size

  values = [
    data.template_file.external_secrets.rendered,
  ]
}

resource "helm_release" "reloader" {
  name        = "reloader"
  chart       = local.reloader.chart
  repository  = local.reloader.repository
  version     = local.reloader.chart_version
  namespace   = module.sys_namespace.name
  wait        = false
  max_history = var.helm_release_history_size
}

#tfsec:ignore:aws-iam-no-policy-wildcards
module "aws_iam_external_secrets" {
  source = "../modules/aws-iam-eks-trusted"

  name              = "${local.name}-ext-secrets"
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "ssm:GetParameter",
        "Resource" : "*"
      }
    ]
  })
}
