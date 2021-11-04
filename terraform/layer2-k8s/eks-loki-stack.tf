locals {
  loki-stack = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "loki-stack")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "loki-stack")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "loki-stack")], "version", null)
  }
  grafana_loki_password = random_string.grafana_loki_password.result

  loki_stack_template = templatefile("${path.module}/templates/loki-stack-values.yaml",
    {
      grafana_domain_name  = "grafana-${local.domain_suffix}"
      grafana_password     = local.grafana_loki_password
      gitlab_client_id     = local.grafana_gitlab_client_id
      gitlab_client_secret = local.grafana_gitlab_client_secret
      gitlab_group         = local.grafana_gitlab_group
  })
}

resource "helm_release" "loki_stack" {
  name        = "loki-stack"
  chart       = local.loki-stack.chart
  repository  = local.loki-stack.repository
  version     = local.loki-stack.chart_version
  namespace   = module.monitoring_namespace.name
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    local.loki_stack_template
  ]

  depends_on = [helm_release.prometheus_operator]
}

resource "random_string" "grafana_loki_password" {
  length  = 20
  special = true
}
