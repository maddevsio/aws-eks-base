output "role_arn" {
  description = "aws_iam_role.external_dns.arn"
  value       = aws_iam_role.this.arn
}
