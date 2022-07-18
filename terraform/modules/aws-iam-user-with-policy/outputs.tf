
output "access_key_id" {
  value       = aws_iam_access_key.this_user.id
  sensitive   = true
  description = "AWS ACCESS_KEY_ID"
  depends_on  = [aws_iam_access_key.this_user]
}

output "access_secret_key" {
  value       = aws_iam_access_key.this_user.secret
  sensitive   = true
  description = "AWS ACCESS_SECRET_KEY"
  depends_on  = [aws_iam_access_key.this_user]
}
