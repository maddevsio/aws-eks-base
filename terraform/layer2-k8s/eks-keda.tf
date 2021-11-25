locals {
  keda = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "keda")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "keda")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "keda")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "keda")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "keda")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "keda")].namespace
  }
}

#tfsec:ignore:kubernetes-network-no-public-egress tfsec:ignore:kubernetes-network-no-public-ingress
module "keda_namespace" {
  count = local.keda.enabled ? 1 : 0

  source = "../modules/kubernetes-namespace"
  name   = local.keda.namespace
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
                name = local.keda.namespace
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
  count = local.keda.enabled ? 1 : 0

  name        = local.keda.name
  chart       = local.keda.chart
  repository  = local.keda.repository
  version     = local.keda.chart_version
  namespace   = module.keda_namespace[count.index].name
  max_history = var.helm_release_history_size
}
