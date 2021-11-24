locals {
  reloader = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "reloader")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "reloader")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "reloader")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "reloader")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "reloader")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "reloader")].namespace
  }
}

#tfsec:ignore:kubernetes-network-no-public-egress tfsec:ignore:kubernetes-network-no-public-ingress
module "reloader_namespace" {
  count = local.reloader.enabled ? 1 : 0

  source = "../modules/kubernetes-namespace"
  name   = local.reloader.namespace
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
                name = local.reloader.namespace
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

resource "helm_release" "reloader" {
  count = local.reloader.enabled ? 1 : 0

  name        = local.reloader.name
  chart       = local.reloader.chart
  repository  = local.reloader.repository
  version     = local.reloader.chart_version
  namespace   = module.reloader_namespace[count.index].name
  max_history = var.helm_release_history_size
}
