locals {
  istio = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "istio")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "istio")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "istio")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "istio")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "istio")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "istio")].namespace
  }
  kiali_server = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "kiali")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "kiali")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "kiali")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "kiali")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "kiali")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "kiali")].namespace
  }
  istiod_values                                = <<VALUES
pilot:
  resources:
    requests:
      cpu: "500m"
      memory: "2Gi"
    limits:
      cpu: "500m"
      memory: "2Gi"
  nodeSelector:
    eks.amazonaws.com/capacityType: ON_DEMAND
global:
  imagePullPolicy: IfNotPresent
  proxy:
    autoInject: enabled
    excludeIPRanges: "169.254.169.254/32"
    holdApplicationUntilProxyStarts: true
VALUES
  kiali_server_prometheus_endpoint             = local.victoria_metrics_k8s_stack.enabled ? "http://vmsingle-${local.victoria_metrics_k8s_stack.name}.${local.victoria_metrics_k8s_stack.namespace}:8429" : "http://${local.kube_prometheus_stack.name}-prometheus.${local.kube_prometheus_stack.namespace}:9090"
  kiali_server_grafana_endpoint                = local.victoria_metrics_k8s_stack.enabled ? "http://${local.victoria_metrics_k8s_stack.name}-grafana.${local.victoria_metrics_k8s_stack.namespace}" : "http://${local.kube_prometheus_stack.name}-grafana.${local.kube_prometheus_stack.namespace}"
  kiali_server_values                          = <<VALUES
nameOverride: ${local.kiali_server.name}
fullnameOverride: ${local.kiali_server.name}
auth:
  strategy: "anonymous"
istio_namespace: ${local.istio.namespace}
external_services:
  custom_dashboards:
    enabled: true
  prometheus:
    url: ${local.kiali_server_prometheus_endpoint}
    custom_metrics_url: ${local.kiali_server_prometheus_endpoint}
  grafana:
    url: ${local.kiali_server_grafana_endpoint}
  namespace_label: kubernetes_namespace
server:
  port: 20001
  metrics_enabled: true
  metrics_port: 9090
  web_root: ""
VALUES
  istio_prometheus_service_monitor_cp_manifest = <<VALUES
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: istio-controlplane
  labels:
    release: kube-prometheus-stack
spec:
  jobLabel: istio
  selector:
    matchExpressions:
      - {key: istio, operator: In, values: [mixer,pilot,galley,citadel,sidecar-injector]}
  namespaceSelector:
    any: true
  endpoints:
  - port: http-monitoring
    interval: 15s
VALUES
  istio_prometheus_service_monitor_dp_manifest = <<VALUES
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: istio-dataplane
  labels:
    monitoring: istio-dataplane
    release: kube-prometheus-stack
spec:
  selector:
    matchExpressions:
      - {key: istio-prometheus-ignore, operator: DoesNotExist}
  namespaceSelector:
    any: true
  jobLabel: envoy-stats
  endpoints:
  - path: /stats/prometheus
    targetPort: http-envoy-prom
    interval: 15s
VALUES
}

module "istio_system_namespace" {
  count = local.istio.enabled ? 1 : 0

  source = "../modules/kubernetes-namespace"
  name   = local.istio.namespace
  network_policies = concat([
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
                name = local.istio.namespace
              }
            }
          }
        ]
      }
    },
    {
      name         = "allow-control-plane"
      policy_types = ["Ingress"]
      pod_selector = {
        match_expressions = {
          key      = "app"
          operator = "In"
          values   = ["istiod"]
        }
      }
      ingress = {
        ports = [
          {
            port     = "15017"
            protocol = "TCP"
          }
        ]
        from = [
          {
            ip_block = {
              cidr = "0.0.0.0/0"
            }
          }
        ]
      }
    },
    {
      name         = "allow-https-dns"
      policy_types = ["Ingress"]
      pod_selector = {
        match_expressions = {
          key      = "app"
          operator = "In"
          values   = ["istiod"]
        }
      }
      ingress = {
        ports = [
          {
            port     = "15012"
            protocol = "TCP"
          }
        ]
        from = [
          {
            ip_block = {
              cidr = "0.0.0.0/0"
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
          key      = "app"
          operator = "In"
          values   = ["istiod"]
        }
      }
      ingress = {
        ports = [
          {
            port     = "15014"
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
    ], local.kiali_server.enabled ? [{
      name         = "allow-kiali-namespace"
      policy_types = ["Ingress"]
      pod_selector = {
        match_expressions = {
          key      = "app"
          operator = "In"
          values   = ["istiod"]
        }
      }
      ingress = {
        ports = [
          {
            port     = "15010"
            protocol = "TCP"
          }
        ]
        from = [
          {
            namespace_selector = {
              match_labels = {
                name = local.kiali_server.namespace
              }
            }
          }
        ]
      }
  }] : [])
}

module "kiali_namespace" {
  count = local.kiali_server.enabled ? 1 : 0

  source = "../modules/kubernetes-namespace"
  name   = local.kiali_server.namespace
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
                name = local.kiali_server.namespace
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
          key      = "app"
          operator = "In"
          values   = [local.kiali_server.name]
        }
      }
      ingress = {
        ports = [
          {
            port     = "9090"
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

resource "helm_release" "istio_base" {
  count = local.istio.enabled ? 1 : 0

  name        = "istio-base"
  chart       = "base"
  repository  = local.istio.repository
  version     = local.istio.chart_version
  max_history = var.helm_release_history_size
}

resource "helm_release" "istiod" {
  count = local.istio.enabled ? 1 : 0

  name        = "istiod"
  chart       = "istiod"
  repository  = local.istio.repository
  version     = local.istio.chart_version
  namespace   = module.istio_system_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    local.istiod_values
  ]

  depends_on = [helm_release.istio_base, kubectl_manifest.kube_prometheus_stack_operator_crds]
}

resource "kubectl_manifest" "istio_prometheus_service_monitor_cp" {
  count              = local.istio.enabled ? 1 : 0
  yaml_body          = local.istio_prometheus_service_monitor_cp_manifest
  override_namespace = module.istio_system_namespace[count.index].name
  depends_on         = [helm_release.istiod]
}

resource "kubectl_manifest" "istio_prometheus_service_monitor_dp" {
  count              = local.istio.enabled ? 1 : 0
  yaml_body          = local.istio_prometheus_service_monitor_dp_manifest
  override_namespace = module.istio_system_namespace[count.index].name
  depends_on         = [helm_release.istiod]
}

resource "helm_release" "kiali" {
  count = local.kiali_server.enabled ? 1 : 0

  name        = local.kiali_server.name
  chart       = local.kiali_server.chart
  repository  = local.kiali_server.repository
  version     = local.kiali_server.chart_version
  namespace   = module.kiali_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    local.kiali_server_values
  ]

  depends_on = [helm_release.istiod, kubectl_manifest.kube_prometheus_stack_operator_crds]
}
