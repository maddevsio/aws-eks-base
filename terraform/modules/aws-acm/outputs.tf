output "ssl_certificate_arn" {
  value = var.create_acm_certificate ? module.acm.acm_certificate_arn : data.aws_acm_certificate.main[0].arn
}
