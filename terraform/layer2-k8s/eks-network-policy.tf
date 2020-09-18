resource "helm_release" "calico_daemonset" {
  name      = "calico-daemonset"
  chart     = "../../helm-charts/calico-daemonset"
  namespace = "kube-system"
}

module "dev_ns_network_policy" {
  source                = "../modules/kubernetes-network-policy-namespace"
  namespace             = kubernetes_namespace.dev.metadata[0].name
  allow_from_namespaces = [module.ing_namespace.labels_name]

  depends = [helm_release.calico_daemonset]
}
