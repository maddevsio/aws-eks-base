resource "aws_iam_user" "this_user" {
  count = var.create_user == true ? 1 : 0

  name = var.name
}

resource "aws_iam_access_key" "this_user" {
  count = var.create_user == true ? 1 : 0

  user = aws_iam_user.this_user.0.name
}

resource "aws_iam_user_policy" "this_user" {
  # Need for support multi-buckets
  count = var.create_user == true ? length(var.bucket_names) : 0

  name = "${var.name}-user"
  user = aws_iam_user.this_user.0.name

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:ListBucketMultipartUploads",
        "s3:ListBucketVersions"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.bucket_names[count.index]}"
      ]
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:AbortMultipartUpload",
        "s3:ListMultipartUploadParts"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.bucket_names[count.index]}/${var.path}*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
EOF
}
