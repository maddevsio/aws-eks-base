locals {
  loki-stack = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "loki-stack")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "loki-stack")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "loki-stack")], "version", null)
  }
  grafana_loki_password = random_string.grafana_loki_password.result

  loki_stack_template = templatefile("${path.module}/templates/loki-stack-values.yaml",
    {
      grafana_domain_name  = "grafana-${local.domain_suffix}"
      grafana_password     = local.grafana_loki_password
      gitlab_client_id     = local.grafana_gitlab_client_id
      gitlab_client_secret = local.grafana_gitlab_client_secret
      gitlab_group         = local.grafana_gitlab_group
  })
}

module "loki_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "loki"
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
                name = "loki"
              }
            }
          }
        ]
      }
    },
    {
      name         = "allow-ingress"
      policy_types = ["Ingress"]
      pod_selector = {}
      ingress = {

        from = [
          {
            namespace_selector = {
              match_labels = {
                name = "ingress-nginx"
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
          values   = ["loki-stack"]
        }
      }
      ingress = {
        ports = [
          {
            port     = "http-metrics"
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

resource "random_string" "grafana_loki_password" {
  length  = 20
  special = true
}

resource "helm_release" "loki_stack" {
  name        = "loki-stack"
  chart       = local.loki-stack.chart
  repository  = local.loki-stack.repository
  version     = local.loki-stack.chart_version
  namespace   = module.loki_namespace.name
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    local.loki_stack_template
  ]

  depends_on = [helm_release.prometheus_operator]
}
