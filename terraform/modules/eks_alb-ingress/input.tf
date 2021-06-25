  variable "name" {
  default     = ""
  }
  variable "region" {
  default     = ""
  }
  variable "oidc_provider_arn" {
  default     = ""
  }
  variable "aws-alb-ingress-controller" {
  default     = ""
  }
  variable "chart_name" {
  default     = "aws-alb-ingress-controller"
  }
  variable "repository" {
  default     = ""
  }
  variable "chart_version" {
  default     = "aws-alb-ingress-controller"
  }
  variable "namespace" {
  default     = ""
  }
  variable "max_history" {
  default     = ""
  }

  variable "values" {
  type        = map(any)
  default    = {}
  
