variable "name" {
  description = "Project name, required to create unique resource names"
  type        = string
  default     = ""
}
variable "region" {
  description = "eks infrastructure region"
  type        = string
  default     = ""
}
variable "oidc_provider_arn" {
  description = "ARN of EKS oidc provider"
  type        = string
  default     = ""
}
variable "release_name" {
  description = "Helm  Release name"
  type        = string
  default     = "aws-load-balancer-controller"
}
variable "chart_name" {
  description = "Helm  Chart name"
  type        = string
  default     = "aws-load-balancer-controller"
}
variable "repository" {
  description = "Repository name for eks"
  type        = string
  default     = "https://aws.github.io/eks-charts"
}
variable "chart_version" {
  description = "Chart version repository name"
  type        = string
  default     = "aws-alb-ingress-controller"
}
variable "namespace" {
  description = "Name of kubernetes namespace for alb_ingres"
  type        = string
  default     = ""
}
variable "max_history" {
  description = "How much helm releases to store"
  type        = number
  default     = "5"
}

variable "values" {
  description = "helm chat template file"
  type        = map(any)
  default     = {}
}
variable "eks_cluster_id" {
  description = "EKC identity cluster"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "EKS cluster vps identity"
  type        = string
  default     = ""
}
variable "alb_ingress_image_tag" {
  description = "chart version alb ingress"
  type        = string
  default     = "1.2.3"
}
