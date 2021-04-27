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

# OAUTH PROXY
variable "oauth2_proxy_version" {
  type        = string
  default     = "3.2.5"
  description = "Version of the oauth-proxy chart"
}

# External DNS
variable "external_dns_version" {
  description = "Version of external-dns helm chart"
  default     = "4.9.4"
}

# Cert Manager
variable "cert_manager_version" {
  description = "Version of cert-manager helm chart"
  default     = "1.1.0"
}

# NGINX Ingress
variable "nginx_ingress_controller_version" {
  description = "Version of nginx-ingress helm chart"
  default     = "3.23.0"
}

variable "nginx_ingress_ssl_terminator" {
  description = "Select SSL termination type"
  default     = "lb"
  # options:
  # lb - terminate ssl on loadbalancer side
  # nginx - terminate ssl on nginx side
}

# ALB Ingress
variable "alb_ingress_image_tag" {
  description = "Tag of docker image for alb-ingress controller"
  default     = "v1.1.5"
}

variable "alb_ingress_chart_version" {
  description = "Version of alb-ingress helm chart"
  default     = "1.0.4"
}

# Cluster autoscaler
variable "cluster_autoscaler_version" {
  description = "Version of cluster autoscaler"
  default     = "v1.19.0"
}

variable "cluster_autoscaler_chart_version" {
  description = "Version of cluster autoscaler helm chart"
  default     = "9.9.2"
}

# Prometheus Operator
variable "prometheus_operator_version" {
  description = "Version of prometheus operator helm chart"
  default     = "13.12.0"
}

# Redis
variable "redis_version" {
  description = "Version of redis helm chart"
  default     = "12.7.3"
}

# ELK
variable "elk_version" {
  description = "Version of ELK helm chart"
  default     = "7.8.0"
}

# external secrets
variable "external_secrets_version" {
  description = "Version of external-secrets helm chart"
  default     = "6.3.0"
}

variable "reloader_version" {
  description = "Version of reloader helm chart"
  default     = "0.0.81"
}

variable "prometheus_mysql_exporter_version" {
  description = "Version of prometheus mysql-exporter helm chart"
  default     = "1.1.0"
}

variable "loki_stack" {
  description = "Version of Loki Stack helm chart"
  default     = "2.3.1"
}

variable "aws_node_termination_handler_version" {
  description = "Version of aws-node-termination-handler helm chart"
  default     = "0.13.3"
}

#Gitlab runner
variable "gitlab_runner_version" {
  description = "Version of gitlab runner helm chart"
  default     = "0.26.0"
}

variable "elk_snapshot_retention_days" {
  description = "Days to capture index in snapshot"
  default     = 90
}

variable "elk_index_retention_days" {
  description = "Days before remove index from system elasticsearch"
  default     = 14
}

# Calico
variable "calico_daemonset" {
  description = "Version of calico helm chart"
  default     = "0.3.4"
}

variable "helm_release_history_size" {
  description = "How much helm releases to store"
  default     = 5
}
