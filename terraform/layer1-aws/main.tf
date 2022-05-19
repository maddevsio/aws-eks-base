terraform {
  required_version = "1.1.8"

  required_providers {
    aws = {
      source  = "aws"
      version = "4.10.0"
    }
    kubernetes = {
      source  = "kubernetes"
      version = "2.10.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

resource "aws_ebs_encryption_by_default" "default" {
  enabled = true
}

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
