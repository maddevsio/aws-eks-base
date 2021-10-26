data "template_file" "external_secrets" {
  template = file("${path.module}/templates/external-secrets-values.yaml")

  vars = {
    role_arn = module.aws_iam_external_secrets.role_arn
    region   = local.region
  }
}

resource "helm_release" "external_secrets" {
  name        = "external-secrets"
  chart       = "kubernetes-external-secrets"
  repository  = local.helm_repo_external_secrets
  version     = var.external_secrets_version
  namespace   = kubernetes_namespace.sys.id
  max_history = var.helm_release_history_size

  values = [
    data.template_file.external_secrets.rendered,
  ]
}

resource "helm_release" "reloader" {
  name        = "reloader"
  chart       = "reloader"
  repository  = local.helm_repo_stakater
  version     = var.reloader_version
  namespace   = kubernetes_namespace.sys.id
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
