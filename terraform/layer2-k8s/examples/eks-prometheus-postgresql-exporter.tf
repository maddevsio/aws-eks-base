locals {
  pg_host          = data.aws_ssm_parameter.pg_host.value
  pg_user          = data.aws_ssm_parameter.pg_user.value
  pg_port          = data.aws_ssm_parameter.pg_port.value
  pg_pass          = data.aws_ssm_parameter.pg_pass.value
  pg_database      = data.aws_ssm_parameter.pg_database.value
  pg_exporter_pass = random_string.pg_exporter_pass.result
}

data "template_file" "postgresql_exporter_user" {
  template = file("${path.module}/templates/postgresql-exporter-user-script.yaml")

  vars = {
    pg_host          = local.pg_host
    pg_user          = local.pg_user
    pg_port          = local.pg_port
    pg_pass          = local.pg_pass
    pg_database      = local.pg_database
    pg_exporter_pass = local.pg_exporter_pass
  }
}

resource "helm_release" "postgresql_exporter_user" {
  name      = "pg-exporter-user"
  chart     = "../../helm-charts/pg-exporter-user"
  namespace = kubernetes_namespace.monitoring.id
  wait      = false

  values = [
    data.template_file.postgresql_exporter_user.rendered
  ]
}

data "template_file" "prometheus_postgresql_exporter" {
  template = file("${path.module}/templates/prometheus-postgresql-exporter.yaml")

  vars = {
    pg_host     = local.pg_host
    pg_pass     = local.pg_exporter_pass
    pg_port     = local.pg_port
    pg_database = local.pg_database
  }
}

resource "helm_release" "postgresql_exporter" {
  name       = "prometheus-postgres-exporter"
  chart      = "prometheus-postgres-exporter"
  repository = local.helm_repo_prometheus_community
  version    = "1.4.0"
  namespace  = kubernetes_namespace.monitoring.id
  wait       = false

  values = [
    data.template_file.prometheus_postgresql_exporter.rendered
  ]

  depends_on = [helm_release.postgresql_exporter_user]
}

resource "random_string" "pg_exporter_pass" {
  length  = 32
  special = false
  upper   = true
}

data "aws_ssm_parameter" "pg_host" {
  name = "/${local.name_wo_region}/env/pg_host"
}

data "aws_ssm_parameter" "pg_port" {
  name = "/${local.name_wo_region}/env/pg_port"
}

data "aws_ssm_parameter" "pg_user" {
  name = "/${local.name_wo_region}/env/pg_user"
}

data "aws_ssm_parameter" "pg_database" {
  name = "/${local.name_wo_region}/env/pg_database"
}

data "aws_ssm_parameter" "pg_pass" {
  name = "/${local.name_wo_region}/env/pg_pass"
}
