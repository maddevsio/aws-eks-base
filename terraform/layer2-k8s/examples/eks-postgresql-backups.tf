locals {
  postgresql_backups_template = templatefile("${path.module}/templates/postgresql-backups-values.tmpl",
    {
      name_wo_region = local.name_wo_region
  })
}

resource "helm_release" "postgresql_backups" {
  name        = "postgresql-backups"
  chart       = "../../helm-charts/postgresql-backups"
  namespace   = kubernetes_namespace.prod.id
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    local.postgresql_backups_template
  ]
}



