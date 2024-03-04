terraform {
  required_version = "1.4.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.36.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.19.0"
    }
  }
}
