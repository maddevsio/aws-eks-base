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
  source = "${get_path_to_repo_root()}/terraform//modules/aws-r53"
}

inputs = {
  name            = include.env.locals.name
  domain_name     = include.env.locals.values.domain_name
  create_r53_zone = include.env.locals.values.create_r53_zone
}
