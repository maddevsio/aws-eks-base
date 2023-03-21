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
    helm = {
      source  = "helm"
      version = "2.5.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

data "aws_caller_identity" "current" {}
