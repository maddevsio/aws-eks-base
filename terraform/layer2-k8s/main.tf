terraform {
  required_version = "1.4.4"

  required_providers {
    aws = {
      source  = "aws"
      version = "4.62.0"
    }
    kubernetes = {
      source  = "kubernetes"
      version = "2.19.0"
    }
    helm = {
      source  = "helm"
      version = "2.6.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

data "aws_caller_identity" "current" {}
