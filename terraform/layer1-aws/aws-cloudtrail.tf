#tfsec:ignore:aws-cloudtrail-enable-at-rest-encryption tfsec:ignore:aws-cloudtrail-ensure-cloudwatch-integration
resource "aws_cloudtrail" "main" {
  name                          = local.name
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  enable_log_file_validation    = true
  enable_logging                = true
  is_multi_region_trail         = true

  tags = local.tags
}

#tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-versioning tfsec:ignore:aws-cloudtrail-require-bucket-access-logging
resource "aws_s3_bucket" "cloudtrail" {
  bucket = "${local.name}-aws-cloudtrail-logs"

  tags = local.tags
}

resource "aws_s3_bucket_acl" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    id     = "remove_old_files"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 2
    }
    expiration {
      days = var.cloudtrail_logs_s3_expiration_days
    }
  }
}

#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket                  = aws_s3_bucket.cloudtrail.id
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AWSCloudTrailAclCheck",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "cloudtrail.amazonaws.com"
          },
          "Action" : "s3:GetBucketAcl",
          "Resource" : aws_s3_bucket.cloudtrail.arn
        },
        {
          "Sid" : "AWSCloudTrailWrite",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "cloudtrail.amazonaws.com"
          },
          "Action" : "s3:PutObject",
          "Resource" : "${aws_s3_bucket.cloudtrail.arn}/*",
          "Condition" : {
            "StringEquals" : {
              "s3:x-amz-acl" : "bucket-owner-full-control"
            }
          }
        }
      ]
  })
}
