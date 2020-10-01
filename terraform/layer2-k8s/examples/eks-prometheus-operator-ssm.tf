locals {
  grafana_password         = random_string.grafana_password.result
  grafana_domain_name      = "grafana.${local.domain_name}"
  prometheus_domain_name   = "prometheus.${local.domain_name}"
  alertmanager_domain_name = "alertmanager.${local.domain_name}"
}

resource "random_string" "grafana_password" {
  length  = 20
  special = true
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

module "aws_iam_grafana" {
  source = "../modules/aws-iam-grafana"

  name              = local.name
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
}

module "grafana_gitlab_client_id" {
  source         = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=master"
  parameter_read = ["/demo/infra/grafana_gitlab_client_id"]
}

module "grafana_gitlab_client_secret" {
  source         = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=master"
  parameter_read = ["/demo/infra/grafana_gitlab_client_secret"]
}


data "template_file" "prometheus_operator" {
  template = "${file("${path.module}/templates/prometheus-values.yaml")}"

  vars = {
    prometheus_domain_name   = local.prometheus_domain_name
    alertmanager_domain_name = local.alertmanager_domain_name
    ip_whitelist             = local.ip_whitelist
    default_region           = local.region
    grafana_domain_name      = local.grafana_domain_name
    grafana_password         = local.grafana_password
    role_arn                 = module.aws_iam_grafana.role_arn
    gitlab_client_id         = module.grafana_gitlab_client_id.values[0]
    gitlab_client_secret     = module.grafana_gitlab_client_secret.values[0]
  }
}

resource "helm_release" "prometheus_operator" {
  name       = "prometheus-operator"
  chart      = "prometheus-operator"
  repository = local.helm_repo_stable
  namespace  = kubernetes_namespace.monitoring.id
  version    = var.prometheus_operator_version
  wait       = false

  set {
    name  = "rbac.create"
    value = "true"
  }

  values = [
    "${data.template_file.prometheus_operator.rendered}",
  ]
}

output "grafana_domain_name" {
  value       = local.grafana_domain_name
  description = "Grafana dashboards address"
}

output "alertmanager_domain_name" {
  value       = local.alertmanager_domain_name
  description = "Alertmanager ui address"
}

output "prometheus_domain_name" {
  value       = local.prometheus_domain_name
  description = "Prometheus ui address"
}

output "grafana_admin_password" {
  value       = local.grafana_password
  sensitive   = true
  description = "Grafana admin password"
}
