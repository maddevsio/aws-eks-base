include {
  path = find_in_parent_folders()
}

dependency "layer1_aws" {
  config_path  = "../layer1-aws"
  skip_outputs = true
}
