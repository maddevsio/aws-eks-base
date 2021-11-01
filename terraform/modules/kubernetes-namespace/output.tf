output "name" {
  value       = kubernetes_namespace.this[0].metadata[0].name
  description = "The name of the created namespace (from object metadata)"
}

output "labels_name" {
  value       = kubernetes_namespace.this[0].metadata[0].labels.name
  description = "The value of the name label"
}
