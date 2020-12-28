locals {
  pg_host            = data.aws_ssm_parameter.pg_host
  pg_user            = data.aws_ssm_parameter.pg_user
  pg_port            = data.aws_ssm_parameter.pg_port
  pg_database        = data.aws_ssm_parameter.pg_database
  pg_pass            = data.aws_ssm_parameter.pg_pass
  backups_image_name = "image/postgresql-backups"
}

data "template_file" "postgresql_backups" {
  template = file("${path.module}/templates/postgresql-backups-values.yaml")
  vars = {
    name_wo_region = local.name_wo_region
    image_name     = local.backups_image_name
  }
}

resource "helm_release" "postgresql_backups" {
  name      = "postgresql-backups"
  chart     = "../../helm-charts/postgresql-backups"
  namespace = kubernetes_namespace.sys.id
  wait      = false

  values = [
    data.template_file.postgresql_backups.rendered
  ]
}

resource "helm_release" "postgresql_exporter" {
  name       = "prometheus-postgres-exporter"
  chart      = "prometheus-postgres-exporter"
  repository = local.helm_repo_prometheus_community
  version    = "1.4.0"
  namespace  = kubernetes_namespace.monitoring.id
  wait       = false

  values = [
    <<-EOF
    config:
      datasource:
        host: ${local.pg_host}
        user: ${local.pg_user}
        password: ${local.pg_pass}
        port: ${local.pg_port}
        database: ${local.pg_database}
        sslmode: disable
    serviceMonitor:
      enabled: true
      namespace: monitoring
      labels:
        release: kube-prometheus-stack
    EOF
    ,
  ]
}


data "aws_ssm_parameter" "pg_host" {
  name = "/${local.name_wo_region}/environment/pg_host"
}

data "aws_ssm_parameter" "pg_port" {
  name = "/${local.name_wo_region}/environment/pg_port"
}

data "aws_ssm_parameter" "pg_user" {
  name = "/${local.name_wo_region}/environment/pg_user"
}

data "aws_ssm_parameter" "pg_database" {
  name = "/${local.name_wo_region}/environment/pg_database"
}

data "aws_ssm_parameter" "pg_pass" {
  name = "/${local.name_wo_region}/environment/pg_pass"
}




