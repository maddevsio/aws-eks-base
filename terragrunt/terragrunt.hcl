terragrunt_version_constraint = ">= 0.39"
skip                          = true

locals {
  remote_state_bucket_region = "${get_env("TF_REMOTE_STATE_BUCKET_REGION")}"
  remote_state_bucket        = "${get_env("TF_REMOTE_STATE_BUCKET")}"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    region  = local.remote_state_bucket_region
    bucket  = local.remote_state_bucket
    key     = "${path_relative_to_include()}/terraform.tfstate"
    encrypt = true
    # Uncomment this to use state locking
    # dynamodb_table = "${local.remote_state_bucket}-${path_relative_to_include()}"

    skip_metadata_api_check     = true
    skip_credentials_validation = true
  }
}

