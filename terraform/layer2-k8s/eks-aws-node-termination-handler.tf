resource "helm_release" "aws_node_termination_handler" {
  name       = "aws-node-termination-handler"
  chart      = "aws-node-termination-handler"
  repository = local.helm_repo_eks
  namespace  = "kube-system"
  wait       = false

  set {
    name  = "enableSpotInterruptionDraining"
    value = "true"
  }
}
