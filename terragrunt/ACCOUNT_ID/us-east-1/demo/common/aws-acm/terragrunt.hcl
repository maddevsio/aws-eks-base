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
  paths = ["../aws-r53"]
}

dependency "r53" {
  config_path = "../aws-r53"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  mock_outputs = {
    route53_zone_id = "ZZZZ0ZZZ"
  }
}

terraform {
  source = "${get_path_to_repo_root()}/terraform//modules/aws-acm"
}

inputs = {
  name                   = include.env.locals.name
  domain_name            = include.env.locals.values.domain_name
  create_acm_certificate = include.env.locals.values.create_acm_certificate
  zone_id                = dependency.r53.outputs.route53_zone_id
}

