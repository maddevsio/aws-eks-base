terraform {
  required_version = "~> 0.12.20"

  backend "s3" {
    bucket  = "madops-terraform-state-us-east-1"
    key     = "layer2-k8s/terraform.tfstate"
    region  = "us-east-1"
    encrypt = "true"
  }
}
