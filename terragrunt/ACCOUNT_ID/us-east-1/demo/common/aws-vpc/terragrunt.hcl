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
  source = "${get_path_to_repo_root()}/terraform//modules/aws-vpc"
}

inputs = {
  name = include.env.locals.name
  cidr = include.env.locals.values.vpc_cidr

  azs                = include.env.locals.values.azs
  single_nat_gateway = include.env.locals.values.single_nat_gateway
}
