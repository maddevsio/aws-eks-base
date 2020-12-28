variable allowed_account_ids {
  description = "List of allowed AWS account IDs"
  default     = []
}

variable additional_allowed_ips {
  type    = list
  default = []
}

# OAUTH PROXY
variable oauth2_proxy_version {
  type        = string
  default     = "3.2.5"
  description = "Version of the oauth-proxy chart"
}

# External DNS
variable external_dns_version {
  description = "Version of external-dns helm chart"
  default     = "3.4.2"
}

# Cert Manager
variable cert_manager_version {
  description = "Version of cert-manager helm chart"
  default     = "0.15.1"
}

# NGINX Ingress
variable nginx_ingress_controller_version {
  description = "Version of nginx-ingress helm chart"
  default     = "3.16.1"
}

variable nginx_ingress_ssl_terminator {
  description = "Select SSL termination type"
  default     = "lb"
  # options:
  # lb - terminate ssl on loadbalancer side
  # nginx - terminate ssl on nginx side
}

# ALB Ingress
variable alb_ingress_image_tag {
  description = "Tag of docker image alb-ingress controller"
  default     = "v1.1.5"
}

variable alb_ingress_chart_version {
  description = "Version of alb-ingress helm chart"
  default     = "1.0.4"
}

# Cluster autoscaler
variable cluster_autoscaler_version {
  description = "Version of autoscaler helm chart"
  default     = "1.1.0"
}

# Prometheus Operator
variable prometheus_operator_version {
  description = "Version of prometheus operator helm chart"
  default     = "12.8.1"
}

# Redis
variable redis_version {
  description = "Version of redis helm chart"
  default     = "10.2.1"
}

# ELK
variable elk_version {
  type    = string
  default = "7.8.0"
}

# external secrets
variable external_secrets_version {
  default = "5.1.0"
}

variable reloader_version {
  default = "0.0.66"
}

variable prometheus_mysql_exporter_version {
  default = "0.7.1"
}

variable "loki_stack" {
  type    = string
  default = "2.1.1"
}

variable "loki_datasource_for_prometheus_stack" {
  type    = bool
  default = false
}

variable aws_node_termination_handler_version {
  description = "Version of aws-node-termination-handler helm chart"
  default     = "0.13.2"
}

variable gitlab_runner_version {
  description = "Version of gitlab runner helm chart"
  default     = "0.24.0"
}

variable elk_snapshot_retention_days {
  description = "Days to capture index in snapshot"
  default     = 90
}

variable elk_index_retention_days {
  description = "Days before remove index from system elasticsearch"
  default     = 14
}

variable grafana_gitlab_client_id {
  type    = string
  default = "Id of the GitLab oauth app for grafana"
}

variable grafana_gitlab_client_secret {
  type        = string
  default     = ""
  description = "Secret of the GitLab oauth app for grafana"
}

variable grafana_gitlab_group {
  type        = string
  default     = "madops"
  description = "Gitlab group for grafana oauth"
}

variable "alertmanager_slack_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable slack alerts for alertmanager"
}

variable "alertmanager_slack_channel" {
  type        = string
  default     = "madops-demo-alerts"
  description = "Slack channel for alertmanager alerts"
}

variable kibana_gitlab_group {
  type        = string
  default     = "madops"
  description = "Gitlab group for kibana oauth2"
}

