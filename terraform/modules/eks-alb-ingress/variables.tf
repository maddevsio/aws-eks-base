variable "name" {
  default = ""
}
variable "region" {
  default = ""
}
variable "oidc_provider_arn" {
  default = ""
}
variable "aws-load-balancer-controller" {
  default = "aws-load-balancer-controller"
}
variable "chart_name" {
  default = "aws-load-balancer-controller"
}
variable "repository" {
  default = "https://aws.github.io/eks-charts"
}
variable "chart_version" {
  default = "aws-alb-ingress-controller"
}
variable "namespace" {
  default = ""
}
variable "max_history" {
  default = "5"
}

variable "values" {
  type    = map(any)
  default = {}
}
variable "eks_cluster_id" {
  default = ""
}

variable "vpc_id" {
  default = ""
}
variable "alb_ingress_image_tag" {
  default = "1.2.3"
}
