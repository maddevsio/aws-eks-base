terraform {
  required_version = "0.15.1"

  required_providers {
    aws = {
      source  = "aws"
      version = "3.53.0"
    }
    kubernetes = {
      source  = "kubernetes"
      version = "2.4.1"
    }
  }

  experiments = [module_variable_optional_attrs]
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}
