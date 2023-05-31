terraform {
  required_version = "1.4.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.62.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.19.0"
    }
    helm = {
      source  = "hashicorp/helm"
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
