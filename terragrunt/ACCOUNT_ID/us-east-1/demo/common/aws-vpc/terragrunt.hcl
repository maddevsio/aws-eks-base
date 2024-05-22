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
  required_version = ">= 1.8.3"

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
  source = "${get_path_to_repo_root()}/terraform//modules/aws-vpc"
}

inputs = {
  name               = include.env.locals.name
  cidr               = include.env.locals.values.vpc_cidr
  azs                = include.env.locals.values.azs
  single_nat_gateway = include.env.locals.values.single_nat_gateway
}
