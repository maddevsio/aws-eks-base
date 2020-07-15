output "grafana_domain_name" {
  value       = local.grafana_domain_name
  description = "Grafana dashboards address"
}

output "alertmanager_domain_name" {
  value       = local.alertmanager_domain_name
  description = "Alertmanager ui address"
}

output "prometheus_domain_name" {
  value       = local.prometheus_domain_name
  description = "Prometheus ui address"
}

output "grafana_admin_password" {
  value       = local.grafana_password
  sensitive   = true
  description = "Grafana admin password"
}

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
