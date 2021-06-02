# COMMON VARIABLES

variable "allowed_account_ids" {
  type        = list(string)
  description = "List of allowed AWS account IDs"
  default     = []
}

variable "name" {
  type        = string
  description = "Project name, required to create unique resource names"
}

variable "environment" {
  type        = string
  default     = "demo"
  description = "Env name in case workspace wasn't used"
}

variable "short_region" {
  type        = string
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
  type        = string
  description = "Main public domain name"
}

variable "zone_id" {
  type        = string
  default     = null
  description = "R53 zone id for public domain"
}

variable "create_r53_zone" {
  type        = bool
  default     = false
  description = "Create R53 zone for main public domain"
}

variable "create_acm_certificate" {
  type        = bool
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
  type        = string
  description = "Default CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "allowed_ips" {
  type        = list(any)
  default     = []
  description = "IP addresses allowed to connect to private resources"
}

variable "single_nat_gateway" {
  type        = bool
  default     = true
  description = "Flag to create single nat gateway for all AZs"
}

# EKS
variable "eks_cluster_version" {
  type        = string
  default     = "1.19"
  description = "Version of the EKS K8S cluster"
}

variable "eks_worker_groups" {
  type        = map(object({
    override_instance_types = optional(list(string))
    spot_instance_pools     = optional(number)
    asg_max_size            = number
    asg_min_size            = optional(number)
    asg_desired_capacity    = number
  }))
  description = "EKS Worker groups configuration"
  default = {
    spot = {
      override_instance_types = ["t3.medium", "t3a.medium"]
      spot_instance_pools     = 2
      asg_max_size            = 5
      asg_min_size            = 0
      asg_desired_capacity    = 1
    },
    ondemand = {
      instance_type        = "t3a.medium"
      asg_desired_capacity = 1
      asg_max_size         = 6
    },
    ci = {
      override_instance_types = ["t3.medium", "t3a.medium"]
      spot_instance_pools     = 2
      asg_max_size            = 3
      asg_min_size            = 0
      asg_desired_capacity    = 0
    },
  }
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
  type        = bool
  default     = false
  description = "Flag for eks module to write kubeconfig"
}

# ECR
variable "ecr_repos" {
  type        = list(any)
  default     = ["demo"]
  description = "List of docker repositories"
}

variable "ecr_repo_retention_count" {
  type        = number
  default     = 50
  description = "number of images to store in ECR"
}
