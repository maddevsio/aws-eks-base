locals {
  loki_stack = {
    name          = local.helm_charts[index(local.helm_charts.*.id, "loki-stack")].id
    enabled       = local.helm_charts[index(local.helm_charts.*.id, "loki-stack")].enabled
    chart         = local.helm_charts[index(local.helm_charts.*.id, "loki-stack")].chart
    repository    = local.helm_charts[index(local.helm_charts.*.id, "loki-stack")].repository
    chart_version = local.helm_charts[index(local.helm_charts.*.id, "loki-stack")].version
    namespace     = local.helm_charts[index(local.helm_charts.*.id, "loki-stack")].namespace
  }
}

#tfsec:ignore:kubernetes-network-no-public-egress tfsec:ignore:kubernetes-network-no-public-ingress
module "loki_namespace" {
  count = local.loki_stack.enabled ? 1 : 0

  source = "../modules/kubernetes-namespace"
  name   = local.loki_stack.namespace
  network_policies = [
    {
      name         = "default-deny"
      policy_types = ["Ingress", "Egress"]
      pod_selector = {}
    },
    {
      name         = "allow-this-namespace"
      policy_types = ["Ingress"]
      pod_selector = {}
      ingress = {
        from = [
          {
            namespace_selector = {
              match_labels = {
                name = local.loki_stack.namespace
              }
            }
          }
        ]
      }
    },
    {
      name         = "allow-monitoring"
      policy_types = ["Ingress"]
      pod_selector = {
        match_expressions = {
          key      = "release"
          operator = "In"
          values   = [local.loki_stack.name]
        }
      }
      ingress = {
        ports = [
          {
            port     = "http-metrics"
            protocol = "TCP"
          },
          {
            port     = "3100"
            protocol = "TCP"
          }
        ]
        from = [
          {
            namespace_selector = {
              match_labels = {
                name = "monitoring"
              }
            }
          }
        ]
      }
    },
    {
      name         = "allow-egress"
      policy_types = ["Egress"]
      pod_selector = {}
      egress = {
        to = [
          {
            ip_block = {
              cidr = "0.0.0.0/0"
              except = [
                "169.254.169.254/32"
              ]
            }
          }
        ]
      }
    }
  ]
}

resource "helm_release" "loki_stack" {
  count = local.loki_stack.enabled ? 1 : 0

  name        = local.loki_stack.name
  chart       = local.loki_stack.chart
  repository  = local.loki_stack.repository
  version     = local.loki_stack_version
  namespace   = module.loki_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    file("${path.module}/templates/loki-stack-values.yaml")
  ]

  depends_on = [helm_release.prometheus_operator]
}
