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

  helm_repo_stable               = "https://charts.helm.sh/stable"
  helm_repo_incubator            = "https://charts.helm.sh/incubator"
  helm_repo_certmanager          = "https://charts.jetstack.io"
  helm_repo_gitlab               = "https://charts.gitlab.io"
  helm_repo_eks                  = "https://aws.github.io/eks-charts"
  helm_repo_softonic             = "https://charts.softonic.io"
  helm_repo_elastic              = "https://helm.elastic.co"
  helm_repo_external_secrets     = "https://external-secrets.github.io/kubernetes-external-secrets"
  helm_repo_stakater             = "https://stakater.github.io/stakater-charts"
  helm_repo_cluster_autoscaler   = "https://kubernetes.github.io/autoscaler"
  helm_repo_ingress_nginx        = "https://kubernetes.github.io/ingress-nginx"
  helm_repo_bitnami              = "https://charts.bitnami.com/bitnami"
  helm_repo_prometheus_community = "https://prometheus-community.github.io/helm-charts"
  helm_repo_grafana              = "https://grafana.github.io/helm-charts"
}
