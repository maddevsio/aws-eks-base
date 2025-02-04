include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

dependency "r53" {
  config_path = "../aws-r53"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  mock_outputs = {
    route53_zone_id = "ZZZZ0ZZZ"
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
  }
}
EOF
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

