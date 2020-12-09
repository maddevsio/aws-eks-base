resource "helm_release" "loki_stack" {
  name       = "loki-stack"
  chart      = "loki-stack"
  repository = local.helm_repo_loki_stack
  namespace  = kubernetes_namespace.monitoring.id
  version    = var.loki_stack
  wait       = false

}
