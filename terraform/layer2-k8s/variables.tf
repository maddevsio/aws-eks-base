variable additional_allowed_ips {
  type    = list
  default = []
}

# OAUTH PROXY
variable oauth2_proxy_version {
  type        = string
  default     = "3.2.0"
  description = "Version of the oauth-proxy chart"
}

# External DNS
variable external_dns_version {
  description = "Version of external-dns helm chart"
  default     = "2.16.0"
}

# Certn Manager
variable cert_manager_version {
  description = "Version of cert-manager helm chart"
  default     = "0.15.1"
}

# NGINX Ingress
variable nginx_ingress_controller_version {
  description = "Version of nginx-ingress helm chart"
  default     = "1.39.1"
}

# ALB Ingress
variable alb_ingress_image_tag {
  description = "Tag of docker image alb-ingress controller"
  default     = "v1.1.5"
}

variable alb_ingress_chart_version {
  description = "Version of alb-ingress helm chart"
  default     = "0.1.13"
}

# Cluster autoscaler
variable cluster_autoscaler_version {
  description = "Version of autoscaler helm chart"
  default     = "6.4.0"
}

# Prometheus Operator
variable prometheus_operator_version {
  description = "Version of prometheus operator helm chart"
  default     = "8.15.0"
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

variable kibana_gitlab_group {
  default     = "madops"
  description = "Gitlab group for kibana oauth2"
}

variable kibana_gitlab_client_id {
  type    = string
  default = "Id of the GitLab oauth app for kibana"
}

variable kibana_gitlab_client_secret {
  type        = string
  default     = ""
  description = "Secret of the GitLab oauth app for kibana"
}
