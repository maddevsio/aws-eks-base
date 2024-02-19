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

terraform {
  source = "${get_terragrunt_dir()}/../../../../../terraform//modules/vpc"
}

inputs = {
  name = include.env.locals.name
  cidr = include.env.locals.values.cidr_block

  azs                = include.env.locals.values.azs
  single_nat_gateway = include.env.locals.values.single_nat_gateway
  tags               = include.env.locals.tags
}
