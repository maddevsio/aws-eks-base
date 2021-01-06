data "template_file" "postgresql_backups" {
  template = file("${path.module}/templates/postgresql-backups-values.yaml")

  vars = {
    name_wo_region = local.name_wo_region
  }
}

resource "helm_release" "postgresql_backups" {
  name      = "postgresql-backups"
  chart     = "../../helm-charts/postgresql-backups"
  namespace = kubernetes_namespace.prod.id
  wait      = false

  values = [
    data.template_file.postgresql_backups.rendered
  ]
}





