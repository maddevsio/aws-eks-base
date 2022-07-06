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

variable "name" {
  description = "Project name, required to create unique resource names"
}

variable "environment" {
  default     = "demo"
  description = "Env name in case workspace wasn't used"
}

variable "short_region" {
  description = "The abbreviated name of the region, required to form unique resource names"
  default = {
    us-east-1      = "use1"  # US East (N. Virginia)
    us-east-2      = "use2"  # US East (Ohio)
    us-west-1      = "usw1"  # US West (N. California)
    us-west-2      = "usw2"  # US West (Oregon)
    ap-east-1      = "ape1"  # Asia Pacific (Hong Kong)
    ap-south-1     = "aps1"  # Asia Pacific (Mumbai)
    ap-northeast-2 = "apn2"  # Asia Pacific (Seoul)
    ap-northeast-1 = "apn1"  # Asia Pacific (Tokyo)
    ap-southeast-1 = "apse1" # Asia Pacific (Singapore)
    ap-southeast-2 = "apse2" # Asia Pacific (Sydney)
    ca-central-1   = "cac1"  # Canada (Central)
    cn-north-1     = "cnn1"  # China (Beijing)
    cn-northwest-1 = "cnnw1" # China (Ningxia)
    eu-central-1   = "euc1"  # EU (Frankfurt)
    eu-west-1      = "euw1"  # EU (Ireland)
    eu-west-2      = "euw2"  # EU (London)
    eu-west-3      = "euw3"  # EU (Paris)
    eu-north-1     = "eun1"  # EU (Stockholm)
    sa-east-1      = "sae1"  # South America (Sao Paulo)
    us-gov-east-1  = "usge1" # AWS GovCloud (US-East)
    us-gov-west-1  = "usgw1" # AWS GovCloud (US)
  }
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

# VPC VARIABLES

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Default infrastructure region"
}

variable "az_count" {
  type        = number
  description = "Count of avaiablity zones, min 2"
  default     = 3
}

variable "cidr" {
  description = "Default CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "allowed_ips" {
  type        = list(any)
  default     = []
  description = "IP addresses allowed to connect to private resources"
}

variable "single_nat_gateway" {
  default     = true
  description = "Flag to create single nat gateway for all AZs"
}

# EKS
variable "eks_cluster_version" {
  default     = "1.22"
  description = "Version of the EKS K8S cluster"
}

variable "eks_addons" {
  default = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = "v1.8.7-eksbuild.1"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = "v1.22.6-eksbuild.1"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = "v1.11.0-eksbuild.1"
    }
  }
  description = "A list of installed EKS add-ons"
}

variable "eks_workers_additional_policies" {
  type        = list(any)
  default     = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  description = "Additional IAM policy attached to EKS worker nodes"
}

variable "node_group_spot" {
  type = object({
    instance_type              = string
    max_capacity               = number
    min_capacity               = number
    desired_capacity           = number
    capacity_rebalance         = bool
    use_mixed_instances_policy = bool
    mixed_instances_policy     = any
  })

  default = {
    instance_type              = "t3.medium" # will be overridden
    max_capacity               = 5
    min_capacity               = 0
    desired_capacity           = 1
    capacity_rebalance         = true
    use_mixed_instances_policy = true
    mixed_instances_policy = {
      instances_distribution = {
        on_demand_base_capacity                  = 0
        on_demand_percentage_above_base_capacity = 0
      }

      override = [
        { instance_type = "t3.medium" },
        { instance_type = "t3a.medium" }
      ]
    }
  }
  description = "Spot node group configuration"
}

variable "node_group_ci" {
  type = object({
    instance_type              = string
    max_capacity               = number
    min_capacity               = number
    desired_capacity           = number
    capacity_rebalance         = bool
    use_mixed_instances_policy = bool
    mixed_instances_policy     = any
  })

  default = {
    instance_type              = "t3.medium" # will be overridden
    max_capacity               = 5
    min_capacity               = 0
    desired_capacity           = 0
    capacity_rebalance         = false
    use_mixed_instances_policy = true
    mixed_instances_policy = {
      instances_distribution = {
        on_demand_base_capacity                  = 0
        on_demand_percentage_above_base_capacity = 0
      }

      override = [
        { instance_type = "t3.medium" },
        { instance_type = "t3a.medium" }
      ]
    }
  }
  description = "CI node group configuration"
}

variable "node_group_ondemand" {
  type = object({
    instance_type              = string
    max_capacity               = number
    min_capacity               = number
    desired_capacity           = number
    capacity_rebalance         = bool
    use_mixed_instances_policy = bool
    mixed_instances_policy     = any
  })

  default = {
    instance_type              = "t3a.medium"
    max_capacity               = 5
    min_capacity               = 1
    desired_capacity           = 1
    capacity_rebalance         = false
    use_mixed_instances_policy = false
    mixed_instances_policy     = null
  }
  description = "Default ondemand node group configuration"
}

variable "node_group_br" {
  type = object({
    instance_type              = string
    max_capacity               = number
    min_capacity               = number
    desired_capacity           = number
    capacity_rebalance         = bool
    use_mixed_instances_policy = bool
    mixed_instances_policy     = any
  })

  default = {
    instance_type              = "t3.medium" # will be overridden
    max_capacity               = 5
    min_capacity               = 0
    desired_capacity           = 0
    capacity_rebalance         = true
    use_mixed_instances_policy = true
    mixed_instances_policy = {
      instances_distribution = {
        on_demand_base_capacity                  = 0
        on_demand_percentage_above_base_capacity = 0
      }

      override = [
        { instance_type = "t3.medium" },
        { instance_type = "t3a.medium" }
      ]
    }
  }
  description = "Bottlerocket node group configuration"
}

variable "eks_map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "eks_write_kubeconfig" {
  default     = false
  description = "Flag for eks module to write kubeconfig"
}

variable "eks_cluster_enabled_log_types" {
  type        = list(string)
  default     = ["audit"]
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html). Possible values: api, audit, authenticator, controllerManager, scheduler"
}

variable "eks_cloudwatch_log_group_retention_in_days" {
  type        = number
  default     = 90
  description = "Number of days to retain log events. Default retention - 90 days."
}

variable "eks_cluster_encryption_config_enable" {
  type        = bool
  default     = false
  description = "Enable or not encryption for k8s secrets with aws-kms"
}

variable "eks_cluster_endpoint_public_access" {
  type        = bool
  default     = true
  description = "Enable or not public access to cluster endpoint"
}

variable "eks_cluster_endpoint_private_access" {
  type        = bool
  default     = false
  description = "Enable or not private access to cluster endpoint"
}

variable "pritunl_vpn_server_enable" {
  type        = bool
  default     = false
  description = "Indicates whether or not the Pritunl VPN server is deployed."
}

variable "eks_cluster_endpoint_only_pritunl" {
  type        = bool
  default     = false
  description = "Only Pritunl VPN server will have access to eks endpoint."
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
