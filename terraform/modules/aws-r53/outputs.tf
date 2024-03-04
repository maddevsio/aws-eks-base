output "route53_zone_id" {
  description = "ID of domain zone"
  value       = var.create_r53_zone ? values(module.r53_zone.route53_zone_zone_id)[0] : data.aws_route53_zone.main[0].zone_id
}
