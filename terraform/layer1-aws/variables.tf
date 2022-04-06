# COMMON VARIABLES

variable "allowed_account_ids" {
  description = "List of allowed AWS account IDs"
  default     = []
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
  default     = "1.21"
  description = "Version of the EKS K8S cluster"
}

variable "eks_addons" {
  default = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = "v1.8.4-eksbuild.1"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = "v1.21.2-eksbuild.2"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = "v1.10.2-eksbuild.1"
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
    instance_types       = list(string)
    capacity_type        = string
    max_capacity         = number
    min_capacity         = number
    desired_capacity     = number
    force_update_version = bool
  })

  default = {
    instance_types       = ["t3a.medium", "t3.medium"]
    capacity_type        = "SPOT"
    max_capacity         = 5
    min_capacity         = 0
    desired_capacity     = 1
    force_update_version = true
  }
  description = "Spot node group configuration"
}

variable "node_group_ci" {
  type = object({
    instance_types       = list(string)
    capacity_type        = string
    max_capacity         = number
    min_capacity         = number
    desired_capacity     = number
    force_update_version = bool
  })

  default = {
    instance_types       = ["t3a.medium", "t3.medium"]
    capacity_type        = "SPOT"
    max_capacity         = 5
    min_capacity         = 0
    desired_capacity     = 0
    force_update_version = true
  }
  description = "CI node group configuration"
}

variable "node_group_ondemand" {
  type = object({
    instance_types       = list(string)
    capacity_type        = string
    max_capacity         = number
    min_capacity         = number
    desired_capacity     = number
    force_update_version = bool
  })

  default = {
    instance_types       = ["t3a.medium"]
    capacity_type        = "ON_DEMAND"
    max_capacity         = 5
    min_capacity         = 1
    desired_capacity     = 1
    force_update_version = true
  }
  description = "Default ondemand node group configuration"
}

variable "node_group_br" {
  type = object({
    instance_types       = list(string)
    capacity_type        = string
    max_capacity         = number
    min_capacity         = number
    desired_capacity     = number
    force_update_version = bool
  })

  default = {
    instance_types       = ["t3a.medium", "t3.medium"]
    capacity_type        = "SPOT"
    max_capacity         = 5
    min_capacity         = 0
    desired_capacity     = 0
    force_update_version = true
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
