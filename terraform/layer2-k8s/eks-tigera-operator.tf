locals {
  tigera_operator = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "tigera-operator")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "tigera-operator")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "tigera-operator")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "tigera-operator")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "tigera-operator")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "tigera-operator")].namespace
  }

  tigera_operator_values = <<VALUES
installation:
  kubernetesProvider: EKS
VALUES
}

module "tigera_operator_namespace" {
  count = local.tigera_operator.enabled ? 1 : 0

  source = "../modules/eks-kubernetes-namespace"
  name   = local.tigera_operator.name
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
                name = local.tigera_operator.namespace
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

resource "kubectl_manifest" "calico_felix" {
  count = local.tigera_operator.enabled ? 1 : 0

  yaml_body = <<YAML
apiVersion: crd.projectcalico.org/v1
kind: FelixConfiguration
metadata:
  name: default
spec:
  logSeverityScreen: Warning
  usageReportingEnabled: false
YAML

  depends_on = [
    helm_release.tigera_operator
  ]
}

resource "helm_release" "tigera_operator" {
  count = local.tigera_operator.enabled ? 1 : 0

  name        = local.tigera_operator.name
  chart       = local.tigera_operator.chart
  repository  = local.tigera_operator.repository
  version     = local.tigera_operator.chart_version
  namespace   = module.tigera_operator_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    local.tigera_operator_values
  ]
}
