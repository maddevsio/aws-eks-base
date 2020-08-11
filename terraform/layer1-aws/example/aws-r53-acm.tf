resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  tags = {
    Name        = local.name
    Environment = local.env
  }
}

resource "aws_acm_certificate" "virginia" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  tags = {
    Name        = local.name
    Environment = local.env
  }

  provider = aws.virginia
}

resource "aws_route53_record" "main" {
  name    = aws_acm_certificate.main.domain_validation_options[1].resource_record_name
  type    = aws_acm_certificate.main.domain_validation_options[1].resource_record_type
  zone_id = var.zone_id
  records = [aws_acm_certificate.main.domain_validation_options[1].resource_record_value]
  ttl     = 60
}

output ssl_certificate_arn {
  description = "ARN of SSL certificate"
  value       = aws_acm_certificate.main.arn
}
