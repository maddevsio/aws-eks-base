variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Default infrastructure region"
}

variable "name" {
  description = "Project name, required to create unique resource names"
}

variable "environment" {
  default     = "demo"
  description = "Env name"
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

variable "allowed_ips" {
  type        = list(any)
  default     = []
  description = "IP addresses allowed to connect to private resources"
}

variable "allowed_account_ids" {
  description = "List of allowed AWS account IDs"
  default     = []
}

variable "additional_allowed_ips" {
  type        = list(any)
  default     = []
  description = "IP addresses allowed to connect to private resources"
}

variable "vpc_id" {
  description = "ID of infra VPC"
}

variable "vpc_cidr" {
  description = "Default CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "eks_cluster_id" {
  description = "ID of the created EKS cluster."
}

variable "eks_oidc_provider_arn" {
  description = "ARN of EKS oidc provider"
}

variable "ssl_certificate_arn" {
  description = "ARN of ACM SSL certificate"
}

variable "helm_release_history_size" {
  description = "How much helm releases to store"
  default     = 5
}

variable "nginx_ingress_ssl_terminator" {
  description = "Select SSL termination type"
  default     = "lb"
  # options:
  # lb - terminate ssl on loadbalancer side
  # nginx - terminate ssl on nginx side
}

# Cluster autoscaler
variable "cluster_autoscaler_version" {
  description = "Version of cluster autoscaler"
  default     = "v1.22.0"
}
