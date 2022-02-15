terraform {
  required_version = "1.0.10"

  required_providers {
    aws = {
      source  = "aws"
      version = "3.72.0"
    }
    kubernetes = {
      source  = "kubernetes"
      version = "2.6.1"
    }
  }
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}
