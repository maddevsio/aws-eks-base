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
