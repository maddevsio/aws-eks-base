resource "aws_iam_role" "admin" {
  name_prefix        = "${var.name}-admin"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": { "AWS": "arn:aws:iam::${var.account_id}:root" },
    "Action": "sts:AssumeRole"
  }
}
EOF
}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "admin_billing" {
  role       = aws_iam_role.admin.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
}

resource "aws_iam_group" "admin" {
  name = "${var.name}-admin"
  path = "/users/"
}

resource "aws_iam_group_policy" "admin" {
  name  = "${var.name}-admin"
  group = aws_iam_group.admin.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": "${aws_iam_role.admin.arn}"
  }
}
EOF
}
