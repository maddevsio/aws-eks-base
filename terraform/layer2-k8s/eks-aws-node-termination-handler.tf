resource "helm_release" "aws_node_termination_handler" {
  name        = "aws-node-termination-handler"
  chart       = "aws-node-termination-handler"
  version     = var.aws_node_termination_handler_version
  repository  = local.helm_repo_eks
  namespace   = kubernetes_namespace.sys.id
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    file("${path.module}/templates/aws-node-termination-handler-values.yaml")
  ]

}
