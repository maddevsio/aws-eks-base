variable "name" {
  type        = string
  description = "Name, required to create unique resource names"
}

variable "eks_cluster_id" {
  type        = string
  description = "ID of the created EKS cluster."
}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "ARN of EKS oidc provider"
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

variable "helm" {
  type        = any
  description = "The configuratin of the Karpenter helm release"
  default     = {}
}

variable "nodepools" {
  type        = any
  description = "Kubernetes manifests to create Karpenter Nodepool objects"
  default     = []
}
