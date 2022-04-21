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
