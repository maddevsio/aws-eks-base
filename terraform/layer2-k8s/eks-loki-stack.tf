locals {
  grafana_loki_password = random_string.grafana_loki_password.result

  loki_stack_template = templatefile("${path.module}/templates/loki-stack-values.tmpl",
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
  chart       = "loki-stack"
  repository  = local.helm_repo_grafana
  namespace   = "monitoring"
  version     = var.loki_stack
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    local.loki_stack_template
  ]

  depends_on = [module.kube_prometheus_stack]
}

resource "random_string" "grafana_loki_password" {
  length  = 20
  special = true
}
