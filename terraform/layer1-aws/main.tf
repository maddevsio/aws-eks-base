terraform {
  required_version = "~> 0.12.20"

  backend "s3" {
    bucket  = "madops-terraform-state-us-east-1"
    key     = "layer1-aws/terraform.tfstate"
    region  = "us-east-1"
    encrypt = "true"
  }
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}
