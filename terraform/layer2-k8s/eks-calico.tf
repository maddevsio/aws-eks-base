locals {
  aws-calico = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "aws-calico")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "aws-calico")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "aws-calico")], "version", null)
  }
}

data "template_file" "calico_daemonset" {
  template = file("${path.module}/templates/calico-values.yaml")
}

resource "helm_release" "calico_daemonset" {
  name        = "aws-calico"
  chart       = local.aws-calico.chart
  repository  = local.aws-calico.repository
  version     = local.aws-calico.chart_version
  namespace   = "kube-system"
  max_history = var.helm_release_history_size
  wait        = false

  values = [
    data.template_file.calico_daemonset.rendered,
  ]
}
