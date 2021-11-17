locals {
  aws_calico = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "aws-calico")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "aws-calico")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "aws-calico")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "aws-calico")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "aws-calico")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "aws-calico")].namespace
  }
  aws_calico_values = <<VALUES
calico:
  typha:
    logseverity: Warning #Debug, Info, Warning, Error, Fatal
  node:
    logseverity: Warning #Debug, Info, Warning, Error, Fatal
VALUES
}

resource "helm_release" "calico_daemonset" {
  count = local.aws_calico.enabled ? 1 : 0

  name        = local.aws_calico.name
  chart       = local.aws_calico.chart
  repository  = local.aws_calico.repository
  version     = local.aws_calico.chart_version
  namespace   = local.aws_calico.namespace
  max_history = var.helm_release_history_size

  values = [
    local.aws_calico_values
  ]

}
