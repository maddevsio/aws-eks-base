resource "aws_iam_account_password_policy" "default" {
  minimum_password_length        = var.aws_account_password_policy.minimum_password_length
  password_reuse_prevention      = var.aws_account_password_policy.password_reuse_prevention
  require_lowercase_characters   = var.aws_account_password_policy.require_lowercase_characters
  require_numbers                = var.aws_account_password_policy.require_numbers
  require_uppercase_characters   = var.aws_account_password_policy.require_uppercase_characters
  require_symbols                = var.aws_account_password_policy.require_symbols
  allow_users_to_change_password = var.aws_account_password_policy.allow_users_to_change_password
  max_password_age               = var.aws_account_password_policy.max_password_age
}
