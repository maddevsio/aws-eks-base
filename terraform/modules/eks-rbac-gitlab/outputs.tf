output "sa_name" {
  value       = kubernetes_service_account.main.metadata.0.name
  description = "Executors service account"
}
