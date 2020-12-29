locals {
  pg_host     = data.aws_ssm_parameter.pg_host
  pg_user     = data.aws_ssm_parameter.pg_user
  pg_port     = data.aws_ssm_parameter.pg_port
  pg_database = data.aws_ssm_parameter.pg_database
  pg_pass     = data.aws_ssm_parameter.pg_pass
}

data "template_file" "prometheus_mysql_exporter" {
  template = file("${path.module}/templates/prometheus-postgresql-exporter.yaml")

  vars = {
    pg_host     = local.pg_host
    pg_user     = local.pg_user
    pg_port     = local.pg_port
    pg_database = local.pg_database
    pg_pass     = local.pg_pass
  }
}

resource "helm_release" "postgresql_exporter" {
  name       = "prometheus-postgres-exporter"
  chart      = "prometheus-postgres-exporter"
  repository = local.helm_repo_prometheus_community
  version    = "1.4.0"
  namespace  = kubernetes_namespace.monitoring.id
  wait       = false
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
