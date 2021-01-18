resource "helm_release" "aws_node_termination_handler" {
  name       = "aws-node-termination-handler"
  chart      = "aws-node-termination-handler"
  version    = var.aws_node_termination_handler_version
  repository = local.helm_repo_eks
  namespace  = kubernetes_namespace.sys.id
  wait       = false

  set {
    name  = "enableSpotInterruptionDraining"
    value = "true"
  }
  # https://docs.aws.amazon.com/autoscaling/ec2/userguide/capacity-rebalance.html
  set {
    name  = "enableRebalanceMonitoring"
    value = "true"
  }
}
