locals {
  aws-node-termination-handler = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "aws-node-termination-handler")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "aws-node-termination-handler")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "aws-node-termination-handler")], "version", null)
  }
}

resource "helm_release" "aws_node_termination_handler" {
  name        = "aws-node-termination-handler"
  chart       = local.aws-node-termination-handler.chart
  repository  = local.aws-node-termination-handler.repository
  version     = local.aws-node-termination-handler.chart_version
  namespace   = module.sys_namespace.name
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    file("${path.module}/templates/aws-node-termination-handler-values.yaml")
  ]

}
