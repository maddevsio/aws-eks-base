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
