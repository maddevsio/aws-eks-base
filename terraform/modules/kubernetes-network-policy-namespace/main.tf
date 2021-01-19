# Deny all incoming connections (include from current namespace) to any pod in current namespace
resource "kubernetes_network_policy" "deny-all" {
  metadata {
    name      = "deny-all"
    namespace = var.namespace
  }
  spec {
    pod_selector {
    }

    policy_types = ["Ingress"]
  }

  depends_on = [var.depends]
}

# Allow all connections in current namespace
resource "kubernetes_network_policy" "allow-from-this" {
  metadata {
    name      = "allow-ingress-into-${var.namespace}"
    namespace = var.namespace
  }
  spec {
    pod_selector {
    }

    ingress {
      from {
        pod_selector {
        }
      }
    }

    policy_types = ["Ingress"]
  }

  depends_on = [var.depends]
}

# Allow all incoming connections from selected namespaces
resource "kubernetes_network_policy" "allow-from-ns" {
  count = length(var.allow_from_namespaces)
  metadata {
    name      = "allow-ingress-from-${var.allow_from_namespaces[count.index]}"
    namespace = var.namespace
  }
  spec {
    pod_selector {
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = var.allow_from_namespaces[count.index]
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }

  depends_on = [var.depends]
}
