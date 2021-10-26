resource "aws_iam_user" "this_user" {
  name = var.name
}

resource "aws_iam_access_key" "this_user" {
  user = aws_iam_user.this_user.name
}

resource "aws_iam_user_policy" "this" {
  name = var.name
  user = aws_iam_user.this_user.name

  policy = var.policy
}

data "aws_iam_policy_document" "user_policy" {

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions"
    ]
    effect = "Allow"
    resources = [
      for buckets in var.bucket_names :
    "arn:aws:s3:::${buckets}"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]
    effect = "Allow"
    resources = [
      for buckets in var.bucket_names :
    "arn:aws:s3:::${buckets}/${var.path}*"]
  }
}

