include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "deep"
}

dependencies {
  paths = ["../vpc"]
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  mock_outputs = {
    vpc_id                           = "vpc-0f5b1b5f788888888"
    vpc_cidr                         = "10.0.0.0/16"
    vpc_private_subnets = ["10.0.0.0/16"]
    vpc_public_subnets = ["10.0.0.0/16"]
    vpc_intra_subnets = ["10.0.0.0/16"]
  }
}

generate "provider-k8s" {
  path      = "provider-k8s.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "kubernetes" {
      host                   = module.eks.cluster_endpoint
      cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
      token                  = data.aws_eks_cluster_auth.main.token
    }

    data "aws_eks_cluster_auth" "main" {
      name = module.eks.cluster_name
    }

    data "aws_caller_identity" "current" {}
    output "eks_auth_token" {
      sensitive = true
      value       = data.aws_eks_cluster_auth.main.token
    }
    output "cluster_ca_certificate" {
      sensitive = true
      value       = base64decode(module.eks.cluster_certificate_authority_data)
    }
  EOF
}

terraform {
  source = "${get_terragrunt_dir()}/../../../../terraform//modules/eks"
}

inputs = {
  name = include.env.locals.name
  env = include.env.locals.values.environment
  tags = include.env.locals.tags
 
  vpc_id = dependency.vpc.outputs.vpc_id
  private_subnets = dependency.vpc.outputs.vpc_private_subnets
  public_subnets = dependency.vpc.outputs.vpc_public_subnets
  intra_subnets = dependency.vpc.outputs.vpc_intra_subnets
}