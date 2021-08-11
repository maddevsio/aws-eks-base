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

  ssl_certificate_arn = var.create_acm_certificate ? module.acm.this_acm_certificate_arn : data.aws_acm_certificate.main[0].arn

  zone_id = var.create_r53_zone ? keys(module.r53_zone.this_route53_zone_zone_id)[0] : (var.zone_id != null ? var.zone_id : data.aws_route53_zone.main[0].zone_id)

  # VPC
  cidr_subnets = [for cidr_block in cidrsubnets(var.cidr, 2, 2, 2, 2) : cidrsubnets(cidr_block, 4, 4, 4, 4)]

  private_subnets  = chunklist(local.cidr_subnets[0], var.az_count)[0]
  public_subnets   = chunklist(local.cidr_subnets[1], var.az_count)[0]
  database_subnets = chunklist(local.cidr_subnets[2], var.az_count)[0]
  intra_subnets    = chunklist(local.cidr_subnets[3], var.az_count)[0]

  azs = data.aws_availability_zones.available.names

  # EKS
  eks_map_roles = concat(var.eks_map_roles,
    [
      {
        rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/administrator"
        username = "administrator"
        groups = [
        "system:masters"]
    }]
  )

  worker_tags = [
    {
      "key"                 = "k8s.io/cluster-autoscaler/enabled"
      "propagate_at_launch" = "false"
      "value"               = "true"
    },
    {
      "key"                 = "k8s.io/cluster-autoscaler/${local.name}"
      "propagate_at_launch" = "false"
      "value"               = "true"
    }
  ]
}
