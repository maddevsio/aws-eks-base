resource "aws_s3_bucket" "rds_backup_wp" {
  bucket = "${local.name}-rds-backup-wp"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  tags = {
    Name        = "${local.name}-rds-backup-wp"
    Environment = local.env
  }
}

resource "aws_s3_bucket_public_access_block" "rds_backup_wp" {
  bucket = aws_s3_bucket.rds_backup_wp.id

  # Block new public ACLs and uploading public objects
  block_public_acls = true
  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true
  # Block new public bucket policies
  block_public_policy = true
  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}
