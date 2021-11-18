locals {
  istio_operator = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "istio-operator")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "istio-operator")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "istio-operator")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "istio-operator")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "istio-operator")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "istio-operator")].namespace
  }
  istio_operator_resources = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "istio-operator-resources")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "istio-operator-resources")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "istio-operator-resources")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "istio-operator-resources")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "istio-operator-resources")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "istio-operator-resources")].namespace
  }
  istio_resources = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "istio-resources")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "istio-resources")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "istio-resources")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "istio-resources")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "istio-resources")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "istio-resources")].namespace
  }
  kiali_server = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "kiali")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "kiali")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "kiali")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "kiali")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "kiali")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "kiali")].namespace
  }
  istio_operator_values                 = <<VALUES
hub: docker.io/istio
tag: 1.8.1
operatorNamespace: istio-operator
watchedNamespaces: istio-system
VALUES
  istio_operator_default_profile_values = <<VALUES
istioOperator:
  components:
    pilot:
      k8s:
        resources:
          requests:
            cpu: "500m"
            memory: "2Gi"
          limits:
            cpu: "500m"
            memory: "2Gi"
    ingressGateways:
    - name: istio-ingressgateway
      enabled: true
      k8s:
        serviceAnnotations:
          service.beta.kubernetes.io/aws-load-balancer-internal: "true" #Internal LB will be run
        service:
          ports:
            - port: 15021
              targetPort: 15021
              name: status-port
              protocol: TCP
            - port: 5100
              targetPort: 5100
              name: grpc
              protocol: TCP
    egressGateways:
    - name: istio-egressgateway
      enabled: false
  meshConfig:
    defaultConfig:
      holdApplicationUntilProxyStarts: true
      proxyStatsMatcher:
        inclusionRegexps:
          - .*circuit_breakers.*
        inclusionPrefixes:
          - upstream_rq_retry
          - upstream_cx
    # accessLogFile: /dev/stdout  #Uncomment this if you want to get Envoy logs

  values:
    global:
      proxy:
        # This controls the default 'policy' in the sidecar injector.
        autoInject: disabled # we don't inject sidecar by default even if namespace is annotated.
    sidecarInjectorWebhook:
      injectedAnnotations:
        cluster-autoscaler.kubernetes.io/safe-to-evict: true # https://github.com/kubeflow/pipelines/issues/4530
VALUES
  istio_resources_values                = <<VALUES
# We create istio resource 'Gateway' with name 'ingress-gateway' and open port 5100 for all vhosts. This configuration is related to istio-ingressgateway settings
ingressGateway:
  enabled: true
  servers:
  - port:
      number: 5100
      name: grpc
      protocol: GRPC
    hosts:
    - "*"
VALUES
  kiali_server_values                   = <<VALUES
nameOverride: "kiali"
fullnameOverride: "kiali"
external_services:
  custom_dashboards:
    enabled: true
  prometheus:
    url: http://kube-prometheus-stack-prometheus.monitoring:9090
    custom_metrics_url: http://kube-prometheus-stack-prometheus.monitoring:9090
  grafana:
    url: http://kube-prometheus-stack-grafana.monitoring
  namespace_label: kubernetes_namespace
server:
  port: 20001
  metrics_enabled: true
  metrics_port: 9090
  web_root: ""
VALUES
}

module "istio_system_namespace" {
  count = local.istio_operator_resources.enabled ? 1 : 0

  source = "../modules/kubernetes-namespace"
  name   = local.istio_operator_resources.namespace
}

module "kiali_namespace" {
  count = local.kiali_server.enabled ? 1 : 0

  source = "../modules/kubernetes-namespace"
  name   = local.kiali_server.namespace
}

resource "helm_release" "istio_operator" {
  count = local.istio_operator.enabled ? 1 : 0

  name        = local.istio_operator.name
  chart       = local.istio_operator.chart
  repository  = local.istio_operator.repository
  version     = local.istio_operator.chart_version
  max_history = var.helm_release_history_size

  values = [
    local.istio_operator_values
  ]

}

resource "helm_release" "istio_operator_resources" {
  count = local.istio_operator_resources.enabled ? 1 : 0

  name        = local.istio_operator_resources.name
  chart       = local.istio_operator_resources.chart
  repository  = local.istio_operator_resources.repository
  version     = local.istio_operator_resources.chart_version
  namespace   = module.istio_system_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    local.istio_operator_default_profile_values
  ]

  depends_on = [helm_release.istio_operator, helm_release.prometheus_operator]
}

resource "time_sleep" "wait_10_seconds" {
  count = local.istio_resources.enabled ? 1 : 0

  create_duration = "10s"

  depends_on = [helm_release.istio_operator_resources]
}

resource "helm_release" "istio_resources" {
  count = local.istio_resources.enabled ? 1 : 0

  name        = local.istio_resources.name
  chart       = local.istio_resources.chart
  repository  = local.istio_resources.repository
  version     = local.istio_resources.chart_version
  namespace   = module.istio_system_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    local.istio_resources_values
  ]

  depends_on = [time_sleep.wait_10_seconds]
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

  depends_on = [helm_release.istio_operator, helm_release.prometheus_operator]
}
