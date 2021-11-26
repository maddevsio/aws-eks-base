# Use this as name base for all resources:
locals {
  # COMMON
  env            = terraform.workspace == "default" ? var.environment : terraform.workspace
  short_region   = var.short_region[var.region]
  name           = "${var.name}-${local.env}-${local.short_region}"
  name_wo_region = "${var.name}-${local.env}"
  domain_name    = var.domain_name
  account_id     = data.aws_caller_identity.current.account_id

  tags = {
    Name        = local.name
    Environment = local.env
  }

  ssl_certificate_arn = var.create_acm_certificate ? module.acm.acm_certificate_arn : data.aws_acm_certificate.main[0].arn

  zone_id = var.create_r53_zone ? keys(module.r53_zone.route53_zone_zone_id)[0] : (var.zone_id != null ? var.zone_id : data.aws_route53_zone.main[0].zone_id)
}
