
resource "kubernetes_resource_quota" "this" {
  count = var.enable && length(var.resource_quotas) > 0 ? length(var.resource_quotas) : 0

  metadata {
    name      = var.resource_quotas[count.index].name
    namespace = kubernetes_namespace.this[0].id
  }
  spec {
    hard   = var.resource_quotas[count.index].hard
    scopes = lookup(var.resource_quotas[count.index], "scopes", null)
    dynamic "scope_selector" {
      for_each = lookup(var.resource_quotas[count.index], "scope_selector", null) != null ? [var.resource_quotas[count.index].scope_selector] : []
      content {
        match_expression {
          scope_name = lookup(scope_selector.value, "scope_name", null)
          operator   = lookup(scope_selector.value, "operator", null)
          values     = lookup(scope_selector.value, "values", null)
        }
      }
    }
  }
}
