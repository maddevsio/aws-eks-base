
output "domain_name" {
  description = "Domain name"
  value       = var.domain_name
}

output "route53_zone_id" {
  description = "ID of domain zone"
  value       = local.zone_id
}

output "allowed_ips" {
  description = "List of allowed ip's, used for direct ssh access to instances."
  value       = var.allowed_ips
}

output "ssl_certificate_arn" {
  description = "ARN of SSL certificate"
  value       = local.ssl_certificate_arn
}

