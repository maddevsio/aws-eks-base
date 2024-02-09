locals {
  values = merge(
    yamldecode(file(find_in_parent_folders("region.yaml"))),
    yamldecode(file("env.yaml"))
  )
  name           = "${local.values.name}-${local.values.environment}-${local.values.short_region[local.values.region]}"
  name_wo_region = "${local.values.name}-${local.values.environment}"
  tags = {
    Name        = local.values.name
    Environment = local.values.environment
  }
}

inputs = local.values

generate "provider-aws" {
  path      = "provider-aws.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.values.region}"
      default_tags {
        tags = {
          Name        = "${local.name}"
          Environment = "${local.values.environment}"
          Terraform   = "true"
        }
      }
    }
  EOF
}


