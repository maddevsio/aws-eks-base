
output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "eks_kubectl_console_config" {
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
  description = "description"
  depends_on  = []
}

output "eks_cluster_id" {
  value = module.eks.cluster_name
}

output "eks_oidc_provider_arn" {
  description = "ARN of EKS oidc provider"
  value       = module.eks.oidc_provider_arn
}

output "node_group_default_iam_role_arn" {
  value = module.eks.self_managed_node_groups["default"].iam_role_arn
}

output "node_group_default_iam_role_name" {
  value = module.eks.self_managed_node_groups["default"].iam_role_name
}

