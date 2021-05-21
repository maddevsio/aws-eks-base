module "kube_prometheus_stack" {
  source = "../modules/eks-prometheus-stack"
  count  = var.kube_prometheus_stack_enable ? true : false

  name                  = local.name
  region                = local.region
  domain_suffix         = local.domain_suffix
  eks_oidc_provider_arn = local.eks_oidc_provider_arn
  ip_whitelist          = local.ip_whitelist
}


