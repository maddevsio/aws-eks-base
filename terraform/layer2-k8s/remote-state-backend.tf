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
