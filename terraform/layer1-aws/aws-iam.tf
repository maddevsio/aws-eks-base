resource "aws_iam_account_password_policy" "default" {
  count = var.aws_account_password_policy.create ? 1 : 0

  minimum_password_length        = var.aws_account_password_policy.minimum_password_length
  password_reuse_prevention      = var.aws_account_password_policy.password_reuse_prevention
  require_lowercase_characters   = var.aws_account_password_policy.require_lowercase_characters
  require_numbers                = var.aws_account_password_policy.require_numbers
  require_uppercase_characters   = var.aws_account_password_policy.require_uppercase_characters
  require_symbols                = var.aws_account_password_policy.require_symbols
  allow_users_to_change_password = var.aws_account_password_policy.allow_users_to_change_password
  max_password_age               = var.aws_account_password_policy.max_password_age
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "4.14.0"

  role_name             = "${local.name}-vpc-cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = local.tags
}
