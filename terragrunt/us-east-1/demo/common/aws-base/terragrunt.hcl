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
    vpc_id              = "vpc-0f5b1b5f788888888"
    vpc_cidr            = "10.0.0.0/16"
    vpc_private_subnets = ["10.0.0.0/16"]
    vpc_public_subnets  = ["10.0.0.0/16"]
    vpc_intra_subnets   = ["10.0.0.0/16"]
  }
}

terraform {
  source = "${get_terragrunt_dir()}/../../../../../terraform//layer1-aws"
}

inputs = {
  name = include.env.locals.name
  env  = include.env.locals.values.environment
  tags = include.env.locals.tags

  vpc_id                  = dependency.vpc.outputs.vpc_id
  private_subnets         = dependency.vpc.outputs.vpc_private_subnets
  public_subnets          = dependency.vpc.outputs.vpc_public_subnets
  intra_subnets           = dependency.vpc.outputs.vpc_intra_subnets
  is_this_payment_account = false
}