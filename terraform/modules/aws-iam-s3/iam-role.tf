resource "aws_iam_role" "this" {
  count = var.create_role == true ? 1 : 0

  description = var.description
  name_prefix = var.name

  assume_role_policy = data.aws_iam_policy_document.role_policy.json
}

data "aws_iam_policy_document" "role_policy" {

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "oidc.eks.${var.region}.amazonaws.com/id/${regex("[A-Z0-9]{32}", var.oidc_provider_arn)}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}


resource "aws_iam_role_policy" "this" {
  # Need for support multi-buckets
  count = var.create_role == true ? 1 : 0

  name_prefix = var.name
  role        = aws_iam_role.this.0.id

  policy = data.aws_iam_policy_document.policy.json
}

data "aws_iam_policy_document" "policy" {

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
