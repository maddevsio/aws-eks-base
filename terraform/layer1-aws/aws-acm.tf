module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "2.12.0"

  create_certificate = var.create_acm_certificate

  domain_name               = local.domain_name
  subject_alternative_names = ["*.${local.domain_name}"]
  zone_id                   = local.zone_id

  tags = {
    Name        = local.name
    Environment = local.env
  }
}

data "aws_acm_certificate" "main" {
  count = var.create_acm_certificate ? 0 : 1

  domain      = var.domain_name
  statuses    = ["ISSUED", "PENDING_VALIDATION"]
  most_recent = true
}
