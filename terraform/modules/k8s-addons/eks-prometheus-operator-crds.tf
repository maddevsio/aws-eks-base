locals {
  kube_prometheus_stack_operator_crds = [
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.kube_prometheus_stack.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-alertmanagerconfigs.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.kube_prometheus_stack.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-alertmanagers.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.kube_prometheus_stack.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-podmonitors.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.kube_prometheus_stack.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-probes.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.kube_prometheus_stack.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-prometheuses.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.kube_prometheus_stack.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-prometheusrules.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.kube_prometheus_stack.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-servicemonitors.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.kube_prometheus_stack.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-thanosrulers.yaml"
  ]
}

data "http" "kube_prometheus_stack_operator_crds" {
  for_each = (local.victoria_metrics_k8s_stack.enabled || local.kube_prometheus_stack.enabled || local.ingress_nginx.enabled) ? toset(local.kube_prometheus_stack_operator_crds) : []
  url      = each.key
}

resource "kubectl_manifest" "kube_prometheus_stack_operator_crds" {
  for_each          = (local.victoria_metrics_k8s_stack.enabled || local.kube_prometheus_stack.enabled || local.ingress_nginx.enabled) ? { for k, v in data.http.kube_prometheus_stack_operator_crds : yamldecode(v.body).metadata.name => v.body } : {}
  yaml_body         = each.value
  server_side_apply = true
}
