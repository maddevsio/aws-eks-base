terragrunt_version_constraint = ">= 0.39"
skip                          = true

locals {

  values = merge(
    yamldecode(file(find_in_parent_folders("region.yaml"))),
    yamldecode(file(find_in_parent_folders("env.yaml")))
  )

  region              = local.values.region
  environment         = local.values.environment
  remote_state_bucket = "${get_env("TF_REMOTE_STATE_BUCKET")}"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    region = local.region
    bucket = local.remote_state_bucket
    key    = "${path_relative_to_include()}/terraform.tfstate"
    encrypt = true
    # Uncomment this to use state locking
    # dynamodb_table = "${local.remote_state_bucket}-${path_relative_to_include()}"

    skip_metadata_api_check     = true
    skip_credentials_validation = true
  }
}

inputs = local.values
