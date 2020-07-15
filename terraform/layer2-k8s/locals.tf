locals {
  region                         = data.terraform_remote_state.layer1-aws.outputs.region
  short_region                   = data.terraform_remote_state.layer1-aws.outputs.short_region
  az_count                       = data.terraform_remote_state.layer1-aws.outputs.az_count
  name                           = data.terraform_remote_state.layer1-aws.outputs.name
  env                            = data.terraform_remote_state.layer1-aws.outputs.env
  zone_id                        = data.terraform_remote_state.layer1-aws.outputs.route53_zone_id
  domain_name                    = data.terraform_remote_state.layer1-aws.outputs.domain_name
  allowed_ips                    = data.terraform_remote_state.layer1-aws.outputs.allowed_ips
  ip_whitelist                   = join(",", concat(local.allowed_ips, var.additional_allowed_ips))
  vpc_id                         = data.terraform_remote_state.layer1-aws.outputs.vpc_id
  vpc_cidr                       = data.terraform_remote_state.layer1-aws.outputs.vpc_cidr
  eks_cluster_id                 = data.terraform_remote_state.layer1-aws.outputs.eks_cluster_id
  eks_oidc_provider_arn          = data.terraform_remote_state.layer1-aws.outputs.eks_oidc_provider_arn
  ssl_certificate_arn            = data.terraform_remote_state.layer1-aws.outputs.ssl_certificate_arn
  elastic_stack_bucket_name      = data.terraform_remote_state.layer1-aws.outputs.elastic_stack_bucket_name
  cloudwatchlogsbeat_bucket_name = data.terraform_remote_state.layer1-aws.outputs.cloudwatchlogsbeat_bucket_name

  grafana_password = random_string.grafana_password.result

  wp_db_password      = data.terraform_remote_state.layer1-aws.outputs.wp_db["password"]
  wp_db_address       = data.terraform_remote_state.layer1-aws.outputs.wp_db["address"]
  wp_db_username      = data.terraform_remote_state.layer1-aws.outputs.wp_db["username"]
  wp_db_database      = data.terraform_remote_state.layer1-aws.outputs.wp_db["database"]
  wp_db_backup_bucket = data.terraform_remote_state.layer1-aws.outputs.wp_db["s3_backup_bucket"]

  grafana_domain_name      = "grafana.${local.domain_name}"
  prometheus_domain_name   = "prometheus.${local.domain_name}"
  alertmanager_domain_name = "alertmanager.${local.domain_name}"
  kibana_domain_name       = "kibana.${local.domain_name}"
  apm_domain_name          = "apm.${local.domain_name}"

  helm_repo_stable      = "https://kubernetes-charts.storage.googleapis.com"
  helm_repo_incubator   = "https://storage.googleapis.com/kubernetes-charts-incubator"
  helm_repo_certmanager = "https://charts.jetstack.io"
  helm_repo_gitlab      = "https://charts.gitlab.io"
  helm_repo_eks         = "https://aws.github.io/eks-charts"
  helm_repo_softonic    = "https://charts.softonic.io"
  helm_repo_elastic     = "https://helm.elastic.co"
}

resource "random_string" "grafana_password" {
  length  = 20
  special = true
}
