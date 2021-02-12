resource "aws_s3_bucket" "elastic_stack" {
  bucket = "${local.name}-elastic-stack"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  tags = {
    Name        = "${local.name}-elastic-stack"
    Environment = local.env
  }
}

resource "aws_s3_bucket_public_access_block" "elastic_stack_public_access_block" {
  bucket = aws_s3_bucket.elastic_stack.id

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}

output "elastic_stack_bucket_name" {
  value       = aws_s3_bucket.elastic_stack.id
  description = "Name of the bucket for ELKS snapshots"
}
