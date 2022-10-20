locals {
  region                         = var.region
  short_region                   = var.short_region[var.region]
  name                           = "${var.name}-${local.env}-${local.short_region}"
  name_wo_region                 = "${var.name}-${local.env}"
  env                            = var.environment
  zone_id                        = var.zone_id
  domain_name                    = var.domain_name
  domain_suffix                  = "${local.env}.${var.domain_name}"
  allowed_ips                    = var.allowed_ips
  ip_whitelist                   = join(",", concat(local.allowed_ips, var.additional_allowed_ips))
  vpc_id                         = var.vpc_id
  vpc_cidr                       = var.vpc_cidr
  eks_cluster_id                 = var.eks_cluster_id
  eks_certificate_authority_data = data.aws_eks_cluster.main.certificate_authority.0.data
  eks_cluster_endpoint           = data.aws_eks_cluster.main.endpoint
  eks_cluster_arn                = data.aws_eks_cluster.main.arn
  eks_oidc_provider_arn          = var.eks_oidc_provider_arn
  ssl_certificate_arn            = var.ssl_certificate_arn

  helm_releases = yamldecode(file("${path.module}/helm-releases.yaml"))["releases"]
}
