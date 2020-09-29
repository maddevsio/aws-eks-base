data "template_file" "prometheus_mysql_exporter" {
  template = file("${path.module}/templates/prometheus-mysql-exporter.yaml")
}

resource "helm_release" "prometheus_mysql_exporter_wp" {
  name       = "prometheus-mysql-exporter"
  chart      = "prometheus-mysql-exporter"
  repository = local.helm_repo_prometheus_community
  namespace  = kubernetes_namespace.wp.id
  version    = "0.7.1"
  wait       = false

  values = [
    "${data.template_file.prometheus_mysql_exporter.rendered}",
  ]

  # This dep needs for correct apply
  depends_on = [kubernetes_namespace.wp, kubernetes_secret.wp_mysql_exporter]
}
