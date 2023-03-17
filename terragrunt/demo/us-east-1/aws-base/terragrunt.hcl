include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "${get_terragrunt_dir()}/../../../../terraform//layer1-aws"
}
