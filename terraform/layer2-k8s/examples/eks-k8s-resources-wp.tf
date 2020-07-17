locals {
  wp_db_password      = data.terraform_remote_state.layer1-aws.outputs.wp_db["password"]
  wp_db_address       = data.terraform_remote_state.layer1-aws.outputs.wp_db["address"]
  wp_db_username      = data.terraform_remote_state.layer1-aws.outputs.wp_db["username"]
  wp_db_database      = data.terraform_remote_state.layer1-aws.outputs.wp_db["database"]
  wp_db_backup_bucket = data.terraform_remote_state.layer1-aws.outputs.wp_db["s3_backup_bucket"]
}


resource "kubernetes_namespace" "wp" {
  metadata {
    name = "wp"
  }
}

resource "kubernetes_secret" "wp_mysql" {
  metadata {
    name      = "mysql-connection"
    namespace = kubernetes_namespace.wp.id
  }

  data = {
    "db-user"     = local.wp_db_username
    "db-password" = local.wp_db_password
    "db-host"     = local.wp_db_address
    "db-name"     = local.wp_db_database
    "db-url"      = "mysql://${local.wp_db_username}:${local.wp_db_password}@${local.wp_db_address}:3306/${local.wp_db_database}"
  }
}

resource "kubernetes_secret" "wp_mysql_exporter" {
  metadata {
    name      = "mysql-exporter"
    namespace = kubernetes_namespace.wp.id
  }

  data = {
    "DATA_SOURCE_NAME" = "${local.wp_db_username}:${local.wp_db_password}@(${local.wp_db_address}:3306)/${local.wp_db_database}"
  }
}
