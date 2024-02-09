variable "eks_cluster_version" {
  default     = "1.25"
  description = "Version of the EKS K8S cluster"
}

variable "node_group_default" {
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
    instance_type              = "t4g.medium" # will be overridden
    max_capacity               = 3
    min_capacity               = 2
    desired_capacity           = 2
    capacity_rebalance         = true
    use_mixed_instances_policy = true
    mixed_instances_policy = {
      instances_distribution = {
        on_demand_base_capacity                  = 0
        on_demand_percentage_above_base_capacity = 0
      }

      override = [
        { instance_type = "t4g.small" },
        { instance_type = "t4g.medium" }
      ]
    }
  }
  description = "Default node group configuration"
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

variable "eks_cluster_endpoint_only_pritunl" {
  type        = bool
  default     = false
  description = "Only Pritunl VPN server will have access to eks endpoint."
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
