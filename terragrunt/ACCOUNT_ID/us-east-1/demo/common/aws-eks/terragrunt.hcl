include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "../aws-vpc"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  mock_outputs = {
    vpc_id              = "vpc-0f5b1b5f788888888"
    vpc_cidr            = "10.0.0.0/16"
    vpc_private_subnets = ["10.0.0.0/16"]
    vpc_public_subnets  = ["10.0.0.0/16"]
    vpc_intra_subnets   = ["10.0.0.0/16"]
  }
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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "${include.root.locals.tf_providers.kubernetes}"
    }
  }
}
EOF
}

terraform {
  source = "${get_path_to_repo_root()}/terraform//modules/aws-eks"
}

inputs = {
  name                = include.env.locals.name
  env                 = include.env.locals.values.environment
  region              = include.env.locals.values.region
  eks_cluster_version = include.env.locals.values.eks_cluster_version

  vpc_id          = dependency.vpc.outputs.vpc_id
  private_subnets = dependency.vpc.outputs.vpc_private_subnets
  public_subnets  = dependency.vpc.outputs.vpc_public_subnets
  intra_subnets   = dependency.vpc.outputs.vpc_intra_subnets
}
