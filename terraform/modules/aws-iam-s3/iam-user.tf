resource "aws_iam_user" "this_user" {
  count = var.create_user == true ? 1 : 0

  name = var.name
}

resource "aws_iam_access_key" "this_user" {
  count = var.create_user == true ? 1 : 0

  user = aws_iam_user.this_user.0.name
}

resource "aws_iam_user_policy" "this" {
  # Need for support multi-buckets
  count = var.create_user == true ? 1 : 0

  name = "${var.name}-user"
  user = aws_iam_user.this_user.0.name

  policy = data.aws_iam_policy_document.user_policy.json
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

