locals {
  region                = var.region
  short_region          = data.terraform_remote_state.layer1-aws.outputs.short_region
  az_count              = data.terraform_remote_state.layer1-aws.outputs.az_count
  name                  = data.terraform_remote_state.layer1-aws.outputs.name
  env                   = data.terraform_remote_state.layer1-aws.outputs.env
  name_wo_region        = data.terraform_remote_state.layer1-aws.outputs.name_wo_region
  zone_id               = data.terraform_remote_state.layer1-aws.outputs.route53_zone_id
  domain_name           = data.terraform_remote_state.layer1-aws.outputs.domain_name
  domain_suffix         = "${local.env}.${local.domain_name}"
  allowed_ips           = data.terraform_remote_state.layer1-aws.outputs.allowed_ips
  ip_whitelist          = join(",", concat(local.allowed_ips, var.additional_allowed_ips))
  vpc_id                = data.terraform_remote_state.layer1-aws.outputs.vpc_id
  vpc_cidr              = data.terraform_remote_state.layer1-aws.outputs.vpc_cidr
  eks_cluster_id        = data.terraform_remote_state.layer1-aws.outputs.eks_cluster_id
  eks_oidc_provider_arn = data.terraform_remote_state.layer1-aws.outputs.eks_oidc_provider_arn

  helm_releases = yamldecode(file("${path.module}/helm-releases.yaml"))["releases"]
}
