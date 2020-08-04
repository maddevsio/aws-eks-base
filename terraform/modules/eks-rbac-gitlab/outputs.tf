output "service_account" {
  value       = kubernetes_service_account.main.metadata.0.name
  description = "Executors service account"
}
