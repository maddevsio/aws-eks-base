module "aws_iam_wp_buckup_s3" {
  source = "../modules/aws-iam-s3"

  name              = "${local.name}-rds-wp"
  region            = local.region
  bucket_names      = [local.wp_db_backup_bucket]
  oidc_provider_arn = local.eks_oidc_provider_arn
  create_user       = true
}

resource "kubernetes_secret" "wp_backup_s3" {
  metadata {
    name      = "mysql-backup-s3-creds"
    namespace = kubernetes_namespace.wp.id
  }

  data = {
    "bucketName"      = local.wp_db_backup_bucket
    "awsEndpoint"     = "https://s3.${local.region}.amazonaws.com"
    "region"          = local.region
    "accessKeyId"     = module.aws_iam_wp_buckup_s3.access_key_id
    "secretAccessKey" = module.aws_iam_wp_buckup_s3.access_secret_key
  }
}

data "template_file" "mysql_backup_wp" {
  template = file("${path.module}/templates/mysql-backup-values.yaml")

  vars = {
    bucket_name = local.wp_db_backup_bucket
    db_host     = local.wp_db_address
    db_name     = local.wp_db_database
  }
}

resource "helm_release" "mysql_backup_wp" {
  name        = "mysql-backup"
  chart       = "mysql-backup"
  repository  = local.helm_repo_softonic
  version     = "2.1.4"
  namespace   = kubernetes_namespace.wp.id
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    data.template_file.mysql_backup_wp.rendered
  ]

  # This dep needs for correct apply
  depends_on = [kubernetes_namespace.wp]
}
