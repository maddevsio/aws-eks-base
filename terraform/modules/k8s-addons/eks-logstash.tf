locals {
  logstash = merge(
    local.helm_releases[index(local.helm_releases.*.id, "logstash")],
  var.logstash)
}

data "template_file" "logstash" {
  template = file("${path.module}/elk-templates/logstash-values.yaml")
  vars = {
    env = "${local.env}"
  }
}

resource "helm_release" "logstash" {
  count = local.logstash.enabled ? 1 : 0

  name        = "logstash"
  chart       = "logstash"
  repository  = local.logstash.repository
  version     = local.logstash.chart_version

  namespace   = "elk"
  timeout     = "900"
  max_history = var.helm_release_history_size

  values = compact(
    [data.template_file.logstash.rendered,
      try(local.logstash.helm_values_override, null),
  ])
}

