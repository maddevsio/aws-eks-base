locals {
  istio_operator = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "istio-operator")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "istio-operator")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "istio-operator")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "istio-operator")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "istio-operator")].version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "istio-operator")].namespace
  }
  istio_operator_resources = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "istio-operator-resources")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "istio-operator-resources")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "istio-operator-resources")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "istio-operator-resources")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "istio-operator-resources")].version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "istio-operator-resources")].namespace
  }
  istio_resources = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "istio-resources")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "istio-resources")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "istio-resources")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "istio-resources")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "istio-resources")].version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "istio-resources")].namespace
  }
  kiali_server = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "kiali")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "kiali")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "kiali")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "kiali")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "kiali")].version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "kiali")].namespace
  }
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
    file("${path.module}/templates/istio/istio-operator-values.yaml")
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
    file("${path.module}/templates/istio/istio-resources-values.yaml")
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
    file("${path.module}/templates/istio/istio-resources-values.yaml")
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
    file("${path.module}/templates/istio/istio-kiali-values.yaml")
  ]

  depends_on = [helm_release.istio_operator, helm_release.prometheus_operator]
}
