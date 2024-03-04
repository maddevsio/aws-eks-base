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
