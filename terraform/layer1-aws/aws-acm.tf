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
  version = "4.3.2"

  create_certificate = var.create_acm_certificate

  domain_name = local.domain_name
  zone_id     = local.zone_id
  subject_alternative_names = [
  "*.${local.domain_name}"]

  tags = local.tags
}
