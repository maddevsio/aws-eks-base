variable "name" {
  type        = string
  description = "Project name, required to create unique resource names"
}

variable "aws_cis_benchmark_alerts" {
  type = any
  default = {
    "enabled" = "false"
    "email"   = "demo@example.com" # where to send alerts
    "rules" = {
      "secrets_manager_actions_enabled"          = true
      "parameter_store_actions_enabled"          = true
      "console_login_failed_enabled"             = true
      "kms_cmk_delete_or_disable_enabled"        = true
      "consolelogin_without_mfa_enabled"         = true
      "unauthorized_api_calls_enabled"           = true
      "usage_of_root_account_enabled"            = true
      "iam_policy_changes_enabled"               = true
      "cloudtrail_configuration_changes_enabled" = true
      "s3_bucket_policy_changes_enabled"         = true
      "aws_config_changes_enabled"               = true
      "security_group_changes_enabled"           = true
      "nacl_changes_enabled"                     = true
      "network_gateway_changes_enabled"          = true
      "route_table_changes_enabled"              = true
      "vpc_changes_enabled"                      = true
      "organization_changes_enabled"             = true
    }
  }
  description = "AWS CIS Benchmark alerts configuration"
}
