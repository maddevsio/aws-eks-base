resource "kubernetes_network_policy" "this" {
  count = var.enable && length(var.network_policies) > 0 ? length(var.network_policies) : 0

  metadata {
    name      = var.network_policies[count.index].name
    namespace = kubernetes_namespace.this[0].id
  }
  spec {
    dynamic "pod_selector" {
      for_each = lookup(var.network_policies[count.index], "pod_selector", null) != null ? [var.network_policies[count.index].pod_selector] : []
      content {
        dynamic "match_expressions" {
          for_each = lookup(pod_selector.value, "match_expressions", null) != null ? [pod_selector.value.match_expressions] : []
          content {
            key      = lookup(match_expressions.value, "key", null)
            operator = lookup(match_expressions.value, "operator", null)
            values   = lookup(match_expressions.value, "values", null)
          }
        }
        match_labels = lookup(pod_selector.value, "match_labels", null)
      }
    }

    dynamic "ingress" {
      for_each = lookup(var.network_policies[count.index], "ingress", null) != null ? [var.network_policies[count.index].ingress] : []
      content {
        dynamic "from" {
          for_each = lookup(ingress.value, "from", null) != null ? ingress.value.from : []
          content {

            dynamic "namespace_selector" {
              for_each = lookup(from.value, "namespace_selector", null) != null ? [from.value.namespace_selector] : []
              content {
                match_labels = lookup(namespace_selector.value, "match_labels", null)
                dynamic "match_expressions" {
                  for_each = lookup(namespace_selector.value, "match_expressions", null) != null ? [namespace_selector.value.match_expressions] : []
                  content {
                    key      = lookup(match_expressions.value, "key", null)
                    operator = lookup(match_expressions.value, "operator", null)
                    values   = lookup(match_expressions.value, "values", null)
                  }
                }
              }
            }

            dynamic "pod_selector" {
              for_each = lookup(from.value, "pod_selector", null) != null ? [from.value.pod_selector] : []
              content {
                match_labels = lookup(pod_selector.value, "match_labels", null)
                dynamic "match_expressions" {
                  for_each = lookup(pod_selector.value, "match_expressions", null) != null ? [pod_selector.value.match_expressions] : []
                  content {
                    key      = lookup(match_expressions.value, "key", null)
                    operator = lookup(match_expressions.value, "operator", null)
                    values   = lookup(match_expressions.value, "values", null)
                  }
                }
              }
            }

            dynamic "ip_block" {
              for_each = lookup(from.value, "ip_block", null) != null ? [from.value.ip_block] : []
              content {
                cidr   = lookup(ip_block.value, "cidr", null)
                except = lookup(ip_block.value, "except", null)
              }
            }

          }
        }

        dynamic "ports" {
          for_each = lookup(ingress.value, "ports", null) != null ? ingress.value.ports : []
          content {
            port     = ports.value.port
            protocol = ports.value.protocol
          }
        }

      }
    }

    dynamic "egress" {
      for_each = lookup(var.network_policies[count.index], "egress", null) != null ? [var.network_policies[count.index].egress] : []
      content {
        dynamic "to" {
          for_each = lookup(egress.value, "to", null) != null ? egress.value.to : []
          content {

            dynamic "namespace_selector" {
              for_each = lookup(to.value, "namespace_selector", null) != null ? [to.value.namespace_selector] : []
              content {
                match_labels = lookup(namespace_selector.value, "match_labels", null)
                dynamic "match_expressions" {
                  for_each = lookup(namespace_selector.value, "match_expressions", null) != null ? [namespace_selector.value.match_expressions] : []
                  content {
                    key      = lookup(match_expressions.value, "key", null)
                    operator = lookup(match_expressions.value, "operator", null)
                    values   = lookup(match_expressions.value, "values", null)
                  }
                }
              }
            }

            dynamic "pod_selector" {
              for_each = lookup(to.value, "pod_selector", null) != null ? [to.value.pod_selector] : []
              content {
                match_labels = lookup(pod_selector.value, "match_labels", null)
                dynamic "match_expressions" {
                  for_each = lookup(pod_selector.value, "match_expressions", null) != null ? [pod_selector.value.match_expressions] : []
                  content {
                    key      = lookup(match_expressions.value, "key", null)
                    operator = lookup(match_expressions.value, "operator", null)
                    values   = lookup(match_expressions.value, "values", null)
                  }
                }
              }
            }

            dynamic "ip_block" {
              for_each = lookup(to.value, "ip_block", null) != null ? [to.value.ip_block] : []
              content {
                cidr   = lookup(ip_block.value, "cidr", null)
                except = lookup(ip_block.value, "except", null)
              }
            }

          }
        }

        dynamic "ports" {
          for_each = lookup(egress.value, "ports", null) != null ? egress.value.ports : []
          content {
            port     = ports.value.port
            protocol = ports.value.protocol
          }
        }

      }
    }

    policy_types = lookup(var.network_policies[count.index], "policy_types", ["Ingress", "Egress"])
  }

}
