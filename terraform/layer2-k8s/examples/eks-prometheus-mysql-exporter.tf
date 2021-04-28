data "template_file" "prometheus_mysql_exporter" {
  template = file("${path.module}/templates/prometheus-mysql-exporter.yaml")
}

resource "helm_release" "prometheus_mysql_exporter_wp" {
  name        = "prometheus-mysql-exporter"
  chart       = "prometheus-mysql-exporter"
  version     = var.prometheus_mysql_exporter_version
  repository  = local.helm_repo_prometheus_community
  namespace   = kubernetes_namespace.wp.id
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    data.template_file.prometheus_mysql_exporter.rendered
  ]

  # This dep needs for correct apply
  depends_on = [kubernetes_namespace.wp, kubernetes_secret.wp_mysql_exporter]
}
