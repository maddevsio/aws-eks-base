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
  image:
    repository: grafana/loki
    tag: 2.9.11
  rbac:
    create: true
    pspEnabled: false # Due to psp removed in k8s 1.25 and latest loki-stack chart doesn't maintain new PSP version
  resources:
    limits:
      cpu: 1
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 1Gi
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
          - key: karpenter.sh/capacity-type
            operator: In
            values:
              - on-demand

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

module "loki_namespace" {
  count = local.loki_stack.enabled ? 1 : 0

  source = "../eks-kubernetes-namespace"
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
      name         = "allow-monitoring-loki"
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
      name         = "allow-monitoring-promtail"
      policy_types = ["Ingress"]
      pod_selector = {
        match_expressions = {
          key      = "app.kubernetes.io/instance"
          operator = "In"
          values   = [local.loki_stack.name]
        }
      }
      ingress = {
        ports = [
          {
            port     = "3101"
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
