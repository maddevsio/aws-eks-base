include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

generate "providers_versions" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "${include.root.locals.tf_providers.aws}"
    }
  }
}
EOF
}

terraform {
  source = "${get_path_to_repo_root()}/terraform//modules/aws-r53"
}

inputs = {
  name            = include.env.locals.name
  domain_name     = include.env.locals.values.domain_name
  create_r53_zone = include.env.locals.values.create_r53_zone
}
