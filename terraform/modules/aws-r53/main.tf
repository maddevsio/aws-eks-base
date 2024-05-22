data "aws_route53_zone" "main" {
  count = var.create_r53_zone ? 0 : 1

  name         = "${var.domain_name}."
  private_zone = false
}

module "r53_zone" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "2.11.1"

  create = var.create_r53_zone

  zones = {
    (var.domain_name) = {
      comment = var.domain_name
    }
  }
}
