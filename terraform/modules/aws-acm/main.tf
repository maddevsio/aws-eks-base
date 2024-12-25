data "aws_acm_certificate" "main" {
  count = var.create_acm_certificate ? 0 : 1

  domain = var.domain_name
  statuses = [
    "ISSUED",
  "PENDING_VALIDATION"]
  most_recent = true
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  create_certificate = var.create_acm_certificate

  domain_name       = var.domain_name
  zone_id           = var.zone_id
  validation_method = var.validation_method
  subject_alternative_names = [
  "*.${var.domain_name}"]
}
