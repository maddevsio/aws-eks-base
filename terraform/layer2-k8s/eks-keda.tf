locals {
  keda = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "keda")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "keda")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "keda")], "version", null)
  }
}

#tfsec:ignore:kubernetes-network-no-public-egress tfsec:ignore:kubernetes-network-no-public-ingress
module "keda_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "keda"
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
                name = "keda"
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

resource "helm_release" "kedacore" {
  name        = "keda"
  chart       = local.keda.chart
  repository  = local.keda.repository
  version     = local.keda.chart_version
  namespace   = module.keda_namespace.name
  wait        = true
  max_history = var.helm_release_history_size
}
