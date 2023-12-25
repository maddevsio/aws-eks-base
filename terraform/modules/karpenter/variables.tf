variable "eks_cluster_id" {
  default = ""
}

variable "eks_cluster_endpoint" {
  default = ""
}

variable "eks_oidc_provider_arn" {
  default = ""
}

variable "node_group_default_iam_role_arn" {
  default = ""
}

variable "k8s_namespace" {
  description = "k8s namespace name"
  type        = string
  default     = "karpenter"
}

variable "kubectl_manifests" {
  description = "Extra kubernetes manifests to apply"
  type        = map(string)
  default     = {}
}

variable "extra_helm_values" {
  description = "Extra helm values to merge with the default values"
  type        = any
  default     = ""
}
