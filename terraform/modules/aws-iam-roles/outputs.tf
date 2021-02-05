output "admin_role_arn" {
  description = "IAM role arn"
  value       = aws_iam_role.admin.arn
}

output "admin_role_name" {
  description = "IAM role name"
  value       = aws_iam_role.admin.name
}


output "admin_group_nme" {
  description = "IAM role arn"
  value       = aws_iam_group.admin.name
}
