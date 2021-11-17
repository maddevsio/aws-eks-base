variable "remote_state_bucket" {
  type        = string
  description = "Name of the bucket for terraform state"
}

variable "remote_state_key" {
  type        = string
  default     = "layer1-aws"
  description = "Key of the remote state for terraform_remote_state"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Default infrastructure region"
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
  default     = "v1.21.0"
}
