locals {
  elk = merge(
    local.helm_releases[index(local.helm_releases.*.id, "filebeat")],
  var.elk)
}

data "template_file" "filebeat" {
  template = file("${path.module}/elk-templates/filebeat-values.yaml")
  vars = {
    env = "${local.env}"
  }
}

resource "helm_release" "filebeat" {
  count = local.elk.enabled ? 1 : 0

  name        = "filebeat"
  chart       = "filebeat"
  repository  = local.elk.repository
  version     = local.elk.chart_version

  namespace   = "elk"
  timeout     = "900"
  max_history = var.helm_release_history_size

  values = compact(
    [data.template_file.filebeat.rendered,
      try(local.elk.helm_values_override, null),
  ])
  depends_on = [
    helm_release.logstash
  ]
}

