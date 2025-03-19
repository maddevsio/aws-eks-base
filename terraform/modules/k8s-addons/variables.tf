variable "region" {
  type        = string
  description = "Default infrastructure region"
  default     = "us-east-1"
}

variable "name" {
  type        = string
  description = "Name, required to create unique resource names"
}

variable "name_wo_region" {
  type        = string
  description = "Project name, required to create unique resource names without region suffix"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "demo"
}

variable "domain_name" {
  type        = string
  description = "Main public domain name"
}

variable "zone_id" {
  type        = string
  description = "R53 zone id for public domain"
  default     = null
}

variable "allowed_ips" {
  type        = list(any)
  description = "IP addresses allowed to connect to private resources"
  default     = []
}

variable "allowed_account_ids" {
  type        = list(any)
  description = "List of allowed AWS account IDs"
  default     = []
}

variable "additional_allowed_ips" {
  type        = list(any)
  description = "IP addresses allowed to connect to private resources"
  default     = []
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where resources are located"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block of VPC"
  default     = "10.0.0.0/16"
}

variable "eks_cluster_id" {
  type        = string
  description = "ID of the created EKS cluster."
}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "ARN of EKS oidc provider"
}

variable "ssl_certificate_arn" {
  type        = string
  description = "ARN of ACM SSL certificate"
}

variable "helm_release_history_size" {
  type        = string
  description = "How much helm releases to store"
  default     = 3
}

variable "nginx_ingress_ssl_terminator" {
  type        = string
  description = "Select SSL termination type"
  default     = "lb"
  # options:
  # lb - terminate ssl on loadbalancer side
  # nginx - terminate ssl on nginx side
}

# Cluster autoscaler
variable "cluster_autoscaler_version" {
  type        = string
  description = "Version of cluster autoscaler"
  default     = "v1.28.0"
}

variable "helm_charts_path" {
  type        = string
  description = "where to find the helm charts"
}

variable "node_group_default_iam_role_arn" {
  type        = string
  description = "The IAM Role ARN of a default nodegroup"
  default     = ""
}

variable "node_group_default_iam_role_name" {
  type        = string
  description = "The IAM Role name of a default nodegroup"
  default     = ""
}

variable "elk" {
  type        = any
  default     = {}
  description = "ELK configuration"
}
