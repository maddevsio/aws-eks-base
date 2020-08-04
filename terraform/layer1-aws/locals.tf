# Use this as name base for all resources:
locals {
  env            = terraform.workspace == "default" ? var.environment : terraform.workspace
  short_region   = var.short_region[var.region]
  name           = "${var.name}-${local.env}-${local.short_region}"
  name_wo_region = "${var.name}-${local.env}"
  domain_name    = "${var.domain_name}"
  account_id     = data.aws_caller_identity.current.account_id
}
