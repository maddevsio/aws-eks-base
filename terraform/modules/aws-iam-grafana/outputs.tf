output "role_arn" {
  description = "IAM role arn of grafana"
  value       = aws_iam_role.this.arn
}
