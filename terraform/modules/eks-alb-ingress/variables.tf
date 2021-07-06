variable "name" {
  description = "Project name, required to create unique resource names"
  default     = ""
}
variable "region" {
  description = "eks infrastructure region"
  default     = ""
}
variable "oidc_provider_arn" {
  description = "ARN of EKS oidc provider"
  default     = ""
}
variable "aws-load-balancer-controller" {
  description = "Helm  Release name"
  default     = "aws-load-balancer-controller"
}
variable "chart_name" {
  description = "Helm  Chart name"
  default     = "aws-load-balancer-controller"
}
variable "repository" {
  description = "Repository name for eks"
  default     = "https://aws.github.io/eks-charts"
}
variable "chart_version" {
  description = "Chart version repository name"
  default     = "aws-alb-ingress-controller"
}
variable "namespace" {
  description = "Name of kubernetes namespace for alb_ingres"
  default     = ""
}
variable "max_history" {
  description = "How much helm releases to store"
  default     = "5"
}

variable "values" {
  description = "helm chat template file"
  type        = map(any)
  default     = {}
}
variable "eks_cluster_id" {
  description = "EKC identity cluster"
  default     = ""
}

variable "vpc_id" {
  description = "EKS cluster vps identity"
  default     = ""
}
variable "alb_ingress_image_tag" {
  description = "chart version alb ingress"
  default     = "1.2.3"
}
