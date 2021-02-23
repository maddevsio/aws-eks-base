resource "aws_s3_bucket" "gitlab_runner_cache" {
  bucket = "${local.name}-gitlab-runner-cache"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    id      = "gitlab-runner-cache-lifecycle-rule"
    enabled = true

    tags = {
      "rule" = "gitlab-runner-cache-lifecycle-rule"
    }

    expiration {
      days = 120
    }
  }

  tags = {
    Name        = "${local.name}-gitlab-runner-cache"
    Environment = local.env
  }
}

resource "aws_s3_bucket_public_access_block" "gitlab_runner_cache_public_access_block" {
  bucket = aws_s3_bucket.gitlab_runner_cache.id

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}

output "gitlab_runner_cache_bucket_name" {
  value       = aws_s3_bucket.gitlab_runner_cache.id
  description = "Name of the s3 bucket for gitlab-runner cache"
}
