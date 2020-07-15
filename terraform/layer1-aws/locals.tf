# Use this as name base for all resources:
locals {
  env            = terraform.workspace == "default" ? random_string.default_env.result : terraform.workspace
  short_region   = var.short_region[var.region]
  name           = "${var.name}-${local.env}-${local.short_region}"
  name_wo_region = "${var.name}-${local.env}"
  domain_name    = "${local.env}.${var.domain_name}"
  account_id     = data.aws_caller_identity.current.account_id

  # Passwords for services and secrets
  wp_db_password = random_string.mysql_password_wp.result
  wp_db_database = "d${random_string.mysql_database_wp.result}"
  wp_db_username = "u${random_string.mysql_user_wp.result}"
  wp_db_name     = "${local.name}-wp"
}

resource "random_string" "default_env" {
  length  = 4
  special = false
  upper   = false
}

resource "random_string" "mysql_password_wp" {
  length  = 20
  special = false
}

resource "random_string" "mysql_database_wp" {
  length  = 8
  special = false
}

resource "random_string" "mysql_user_wp" {
  length  = 8
  special = false
}
