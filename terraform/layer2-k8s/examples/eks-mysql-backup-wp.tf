module "aws_iam_wp_buckup_s3" {
  source = "../modules/aws-iam-user-with-policy"

  name = "${local.name}-rds-wp"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads",
          "s3:ListBucketVersions"
        ],
        "Resource" : [
          "arn:aws:s3:::${local.wp_db_backup_bucket}"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ],
        "Resource" : [
          "arn:aws:s3:::${local.wp_db_backup_bucket}/*"
        ]
      }
    ]
  })
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
