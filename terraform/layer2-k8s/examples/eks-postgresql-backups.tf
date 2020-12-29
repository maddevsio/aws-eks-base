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





