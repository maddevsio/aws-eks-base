locals {
  loki_stack = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "loki-stack")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "loki-stack")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "loki-stack")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "loki-stack")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "loki-stack")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "loki-stack")].namespace
  }
  loki_stack_values = <<VALUES
loki:
  enabled: true
  config:
    limits_config:
      enforce_metric_name: false
      reject_old_samples: true
      reject_old_samples_max_age: 168h
  persistence:
    enabled: true
    accessModes:
      - ReadWriteOnce
    size: 10Gi
    storageClassName: advanced
  serviceMonitor:
    enabled: true
    scrapeTimeout: 10s
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: eks.amazonaws.com/capacityType
            operator: In
            values:
              - ON_DEMAND

promtail:
  enabled: true
  serviceMonitor:
    enabled: true
  tolerations:
    - effect: NoSchedule
      operator: Exists

fluent-bit:
  enabled: false
grafana:
  enabled: false
VALUES
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
  version     = local.loki_stack.chart_version
  namespace   = module.loki_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    local.loki_stack_values
  ]

  depends_on = [kubectl_manifest.kube_prometheus_stack_operator_crds]
}
