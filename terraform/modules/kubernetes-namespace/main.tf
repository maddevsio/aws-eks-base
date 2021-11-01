# automatically add name to labels,
# if it is not set
locals {
  labels = merge({
    name = var.name
  }, var.labels)
}

resource "kubernetes_namespace" "this" {
  # option to disable namespace creation
  # e.g. if you want to create namespace only in specific environment
  count = var.enable ? 1 : 0

  metadata {
    annotations = var.annotations
    labels      = local.labels
    name        = var.name
  }

  depends_on = [var.depends]
}

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
      for_each = lookup(var.resource_quotas[count.index], "scope_selector", null) != null ? [var.resource_quotas[count.index]["scope_selector"]] : []
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
