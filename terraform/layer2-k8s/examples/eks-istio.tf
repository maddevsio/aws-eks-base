local {
  istio-operator = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "istio-operator")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "istio-operator")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "istio-operator")], "version", null)
  }
  istio-operator-resources = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "istio-operator-resources")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "istio-operator-resources")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "istio-operator-resources")], "version", null)
  }
  istio-resources = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "istio-resources")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "istio-resources")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "istio-resources")], "version", null)
  }
  kiali-server = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "kiali-server")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "kiali-server")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "kiali-server")], "version", null)
  }
}

resource "helm_release" "istio_operator" {
  name        = "istio-operator"
  chart       = local.istio-operator.chart
  repository  = local.istio-operator.repository
  version     = local.istio-operator.chart_version
  max_history = var.helm_release_history_size
  wait        = true

  values = [
    file("${path.module}/templates/istio/istio-operator-values.yaml")
  ]
}

resource "helm_release" "istio_operator_resources" {
  name        = "istio-operator-resources"
  chart       = local.istio-operator-resources.chart
  repository  = local.istio-operator-resources.repository
  version     = local.istio-operator-resources.chart_version
  namespace   = module.istio_system_namespace.name
  max_history = var.helm_release_history_size
  wait        = true

  values = [
    file("${path.module}/templates/istio/istio-resources-values.yaml")
  ]

  depends_on = [helm_release.istio_operator, helm_release.prometheus_operator]
}

resource "time_sleep" "wait_10_seconds" {
  depends_on = [helm_release.istio_operator_resources]

  create_duration = "10s"
}

resource "helm_release" "istio_resources" {
  name        = "istio-resources"
  chart       = local.istio-resources.chart
  repository  = local.istio-resources.repository
  version     = local.istio-resources.chart_version
  namespace   = module.istio_system_namespace.name
  max_history = var.helm_release_history_size
  wait        = false

  values = [
    file("${path.module}/templates/istio/istio-resources-values.yaml")
  ]

  depends_on = [time_sleep.wait_10_seconds]
}

resource "helm_release" "kiali" {
  name        = "kiali-server"
  chart       = local.kiali-server.chart
  repository  = local.kiali-server.repository
  version     = local.kiali-server.chart_version
  namespace   = module.kiali_namespace.name
  max_history = var.helm_release_history_size
  wait        = false

  values = [
    file("${path.module}/templates/istio/istio-kiali-values.yaml")
  ]
  depends_on = [helm_release.istio_operator, helm_release.prometheus_operator]
}

module "istio_system_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "istio-system"
}

module "kiali_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "kiali"
}
