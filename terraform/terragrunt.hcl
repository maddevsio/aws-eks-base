locals{
  remote_state_bucket = "${get_env("TF_REMOTE_STATE_BUCKET")}"
  region              = "${get_env("TF_REGION", "us-east-1")}"
}

inputs = {
  remote_state_bucket = local.remote_state_bucket
  region              = local.region
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    region         = local.region
    bucket         = local.remote_state_bucket
    key            = "${path_relative_to_include()}/terraform.tfstate"
    dynamodb_table = "${local.remote_state_bucket}-${path_relative_to_include()}"
    encrypt        = true
  }
}
