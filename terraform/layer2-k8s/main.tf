terraform {
  required_version = "~> 0.12.20"

  backend "s3" {
    bucket  = "madops-terraform-state-us-east-1"
    key     = "layer2-k8s/terraform.tfstate"
    region  = "us-east-1"
    encrypt = "true"
  }
}

data "terraform_remote_state" "layer1-aws" {
  backend = "s3"
  config = {
    bucket  = "madops-terraform-state-us-east-1"
    key     = "layer1-aws/terraform.tfstate"
    region  = "us-east-1"
    encrypt = "true"
  }
  workspace = terraform.workspace
}

data "aws_caller_identity" "current" {}
