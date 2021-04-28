resource "helm_release" "istio_operator" {
  name  = "istio-operator"
  chart = "../../helm-charts/istio/istio-operator"

  wait = true

  values = [
    file("${path.module}/templates/istio/istio-operator-values.yaml")
  ]
}

resource "helm_release" "istio_operator_resources" {
  name  = "istio-operator-resources"
  chart = "../../helm-charts/istio/istio-operator-resources"

  namespace   = module.istio_system_namespace.name
  wait        = true
  max_history = var.helm_release_history_size

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
  name  = "istio-resources"
  chart = "../../helm-charts/istio/istio-resources"

  namespace   = module.istio_system_namespace.name
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    file("${path.module}/templates/istio/istio-resources-values.yaml")
  ]

  depends_on = [time_sleep.wait_10_seconds]
}

resource "helm_release" "kiali" {
  name        = "kiali-server"
  chart       = "kiali-server"
  repository  = local.helm_repo_kiali
  namespace   = module.kiali_namespace.name
  version     = var.kiali_version
  wait        = false
  max_history = var.helm_release_history_size

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
