# COMMON VARIABLES

variable "allowed_account_ids" {
  description = "List of allowed AWS account IDs"
  default     = []
}

variable "aws_account_password_policy" {
  type = any
  default = {
    create                         = true
    minimum_password_length        = 14    # Minimum length to require for user passwords
    password_reuse_prevention      = 10    # The number of previous passwords that users are prevented from reusing
    require_lowercase_characters   = true  # If true, password must contain at least 1 lowercase symbol
    require_numbers                = true  # If true, password must contain at least 1 number symbol
    require_uppercase_characters   = true  # If true, password must contain at least 1 uppercase symbol
    require_symbols                = true  # If true, password must contain at least 1 special symbol
    allow_users_to_change_password = true  # Whether to allow users to change their own password
    max_password_age               = 90    # How many days user's password is valid
    hard_expiry                    = false # Don't allow users to set a new password after their password has expired
  }
}

variable "is_this_payment_account" {
  default     = true
  description = "Set it to false if a target account isn't a payer account. This variable is used to apply a configuration for cost allocation tags"
}

variable "domain_name" {
  description = "Main public domain name"
}

variable "zone_id" {
  default     = null
  description = "R53 zone id for public domain"
}

variable "create_r53_zone" {
  default     = false
  description = "Create R53 zone for main public domain"
}

variable "create_acm_certificate" {
  default     = false
  description = "Whether to create acm certificate or use existing"
}

variable "allowed_ips" {
  type        = list(any)
  default     = []
  description = "IP addresses allowed to connect to private resources"
}

# EKS


variable "pritunl_vpn_server_enable" {
  type        = bool
  default     = false
  description = "Indicates whether or not the Pritunl VPN server is deployed."
}

variable "pritunl_vpn_access_cidr_blocks" {
  type        = string
  default     = "127.0.0.1/32"
  description = "IP address that will have access to the web console"
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

variable "cloudtrail_logs_s3_expiration_days" {
  type        = string
  default     = 180
  description = "How many days keep cloudtrail logs on S3"
}

variable "tags" {
  type = any
}
variable "private_subnets" {
  type = list(any)
}
variable "public_subnets" {
  type = list(any)
}
variable "intra_subnets" {
  type = list(any)
}
variable "vpc_id" {

}
variable "region" {

}
variable "env" {

}

variable "name" {

}
