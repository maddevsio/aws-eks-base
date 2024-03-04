include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

include "region" {
  path           = find_in_parent_folders("region.hcl")
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "${get_path_to_repo_root()}/terraform/modules//aws-ebs-encryption-default"
}

inputs = {
  enable = include.region.locals.region_values.aws_ebs_encryption_by_default
}
