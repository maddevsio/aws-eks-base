locals {
  region                         = var.region
  name                           = var.name
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
  eks_certificate_authority_data = var.cluster_ca_certificate
  eks_cluster_endpoint           = var.eks_cluster_endpoint
  eks_oidc_provider_arn          = var.eks_oidc_provider_arn
  ssl_certificate_arn            = var.ssl_certificate_arn

  helm_releases = yamldecode(file("${path.module}/helm-releases.yaml"))["releases"]
}
