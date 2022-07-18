resource "kubernetes_limit_range" "this" {
  count = var.enable ? 1 : 0

  metadata {
    name      = var.name
    namespace = kubernetes_namespace.this[count.index].id
  }
  spec {
    dynamic "limit" {
      for_each = var.limits
      content {
        type                    = lookup(limit.value, "type", null)
        default                 = lookup(limit.value, "default", null)
        default_request         = lookup(limit.value, "default_request", null)
        max                     = lookup(limit.value, "max", null)
        max_limit_request_ratio = lookup(limit.value, "max_limit_request_ratio", null)
        min                     = lookup(limit.value, "min", null)
      }
    }
  }
}
