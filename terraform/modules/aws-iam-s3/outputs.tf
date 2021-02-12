output "role_arn" {
  description = "IAM role arn"
  value       = var.create_role ? aws_iam_role.this.0.arn : null
}

output "access_key_id" {
  value       = var.create_user ? aws_iam_access_key.this_user.0.id : null
  sensitive   = true
  description = "description"
  depends_on  = [aws_iam_access_key.this_user]
}

output "access_secret_key" {
  value       = var.create_user ? aws_iam_access_key.this_user.0.secret : null
  sensitive   = true
  description = "description"
  depends_on  = [aws_iam_access_key.this_user]
}
