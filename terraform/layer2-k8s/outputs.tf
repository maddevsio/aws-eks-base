output "kibana_domain_name" {
  value       = local.kibana_domain_name
  description = "Kibana dashboards address"
}

output "apm_domain_name" {
  value       = local.apm_domain_name
  description = ""
}

output "elasticsearch_elastic_password" {
  value       = random_string.elasticsearch_password.result
  sensitive   = true
  description = "Password of the superuser 'elastic'"
}
