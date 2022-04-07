# Common outputs
output "name" {
  description = "Project name, required to form unique resource names"
  value       = local.name
}

output "name_wo_region" {
  description = "Project name, required to form unique resource names without short region"
  value       = local.name_wo_region
}

output "domain_name" {
  description = "Domain name"
  value       = var.domain_name
}

output "env" {
  description = "Suffix for the hostname depending on workspace"
  value       = local.env
}

output "route53_zone_id" {
  description = "ID of domain zone"
  value       = local.zone_id
}

output "region" {
  description = "Target region for all infrastructure resources"
  value       = var.region
}

output "short_region" {
  description = "The abbreviated name of the region, required to form unique resource names"
  value       = local.short_region
}

output "az_count" {
  description = "Count of avaiablity zones, min 2"
  value       = var.az_count
}

output "allowed_ips" {
  description = "List of allowed ip's, used for direct ssh access to instances."
  value       = var.allowed_ips
}

output "vpc_name" {
  description = "Name of infra VPC"
  value       = module.vpc.name
}

output "vpc_id" {
  description = "ID of infra VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of infra VPC"
  value       = var.cidr
}

output "vpc_public_subnets" {
  description = "Public subnets of infra VPC"
  value       = module.vpc.public_subnets
}

output "vpc_private_subnets" {
  description = "Private subnets of infra VPC"
  value       = module.vpc.private_subnets
}

output "vpc_database_subnets" {
  description = "Database subnets of infra VPC"
  value       = module.vpc.database_subnets
}

output "vpc_intra_subnets" {
  description = "Private intra subnets "
  value       = module.vpc.intra_subnets
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "eks_kubectl_console_config" {
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_id} --region ${var.region}"
  description = "description"
  depends_on  = []
}

output "eks_cluster_id" {
  value = module.eks.cluster_id
}

output "eks_oidc_provider_arn" {
  description = "ARN of EKS oidc provider"
  value       = module.eks.oidc_provider_arn
}

output "ssl_certificate_arn" {
  description = "ARN of SSL certificate"
  value       = local.ssl_certificate_arn
}
