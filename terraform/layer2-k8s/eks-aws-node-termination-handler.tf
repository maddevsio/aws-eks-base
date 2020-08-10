resource "helm_release" "aws_node_termination_handler" {
  name       = "aws-node-termination-handler"
  chart      = "aws-node-termination-handler"
  repository = local.helm_repo_eks
  namespace  = kubernetes_namespace.sys.id
  wait       = false

  set {
    name  = "enableSpotInterruptionDraining"
    value = "true"
  }
}
