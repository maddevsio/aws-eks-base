variable "name" {
  description = "Project name, required to create unique resource names"
  type        = string
}

variable "region" {
  description = "Default infrastructure region"
  type        = string
}

variable "domain_suffix" {
  description = "Domain name used to build subdomains"
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "ARN of EKS oidc provider"
  type        = string
}

variable "helm_repo_prometheus_community" {
  description = "Repository name for kube-prometheus-stack"
  type        = string
  default     = "https://prometheus-community.github.io/helm-charts"
}

variable "kubernetes_namespace" {
  description = "Name of kubernetes namespace for prometheus stack"
  type        = string
  default     = "monitoring"
}

variable "kube_prometheus_stack_version" {
  description = "Kube-prometheus-stack chart version"
  type        = string
}

variable "helm_release_wait" {
  description = "Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as timeout. Defaults to true."
  type        = string
  default     = false
}

variable "helm_release_history_size" {
  description = "How much helm releases to store"
  type        = number
  default     = 5
}

variable "ip_whitelist" {
  description = "Whitelist ip's for access to prometheus and alertmanager"
  type        = string
  default     = ""
}

variable "prometheus_storage_size" {
  description = "Prometheus storage size"
  type        = string
  default     = "30Gi"
}

variable "grafana_enabled" {
  description = "Enable or disable grafana"
  type        = bool
  default     = true
}

variable "grafana_storage_size" {
  description = "Grafana storage size"
  type        = string
  default     = "5Gi"
}

variable "grafana_gitlab_oauth_enabled" {
  description = "Enable or disable gitlab oauth for grafana"
  type        = bool
  default     = false
}

variable "grafana_github_oauth_enabled" {
  description = "Enable or disable github oauth for grafana"
  type        = bool
  default     = false
}

variable "grafana_oauth_client_id" {
  description = "Oauth client id for grafana"
  type        = string
  default     = ""
}

variable "grafana_oauth_client_secret" {
  description = "Oauth client id secret for grafana"
  type        = string
  default     = ""
}

variable "grafana_oauth_gitlab_group" {
  description = "Gitlab group"
  type        = string
  default     = ""
}

variable "grafana_oauth_github_teams_ids" {
  description = "Github teams ids"
  type        = string
  default     = ""
}

variable "grafana_oauth_github_allowed_org" {
  description = "Github allowed organizations"
  type        = string
  default     = ""
}

variable "alertmanager_enabled" {
  description = "Enable or disable alertmanager"
  type        = bool
  default     = false
}

variable "alertmanager_slack_url" {
  description = "Slack webhook for alertmanager"
  type        = string
  default     = ""
}

variable "alertmanager_slack_channel" {
  description = "Slack channel name for alertmanager"
  type        = string
  default     = ""
}

