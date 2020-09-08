output "name" {
  value       = kubernetes_namespace.this[0].metadata[0].name
  description = "The URL of the created resource"
}

output "labels_name" {
  value       = null_resource.labels.triggers.name
  description = "Map of the labels"
}
