output "role_arn" {
  description = "Cluster autoscaler role arn"
  value       = aws_iam_role.this.arn
}
