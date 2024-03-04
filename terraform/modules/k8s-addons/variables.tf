variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Default infrastructure region"
}

variable "name" {
  description = "Project name, required to create unique resource names"
}

variable "name_wo_region" {
  description = "Project name, required to create unique resource names without region suffix"
}

variable "environment" {
  default     = "demo"
  description = "Env name"
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
  default     = "v1.25.0"
}


variable "helm_charts_path" {
  type        = string
  description = "where to find the helm charts"
  default     = "../../helm-charts/"
}

variable "node_group_default_iam_role_arn" {
  description = "The IAM Role ARN of a default nodegroup"
  default     = ""
}

variable "node_group_default_iam_role_name" {
  description = "The IAM Role name of a default nodegroup"
  default     = ""
}
