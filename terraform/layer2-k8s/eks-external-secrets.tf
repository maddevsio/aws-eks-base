module "aws_iam_external_secrets" {
  source = "../modules/aws-iam-ssm"

  name              = local.name
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
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

#module "aws_iam_wp_external_secrets" {
#  source = "../modules/aws-iam-ssm"
#
#  name              = local.name
#  region            = local.region
#  oidc_provider_arn = local.eks_oidc_provider_arn
#  resources         = ["arn:aws:ssm:${local.region}:${data.aws_caller_identity.current.account_id}:parameter/wp/*"]
#}
#
#output wordpress_external_secrets_role_arn {
#  value       = module.aws_iam_wp_external_secrets.role_arn
#}
