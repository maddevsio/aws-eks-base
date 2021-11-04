locals {
  kube-prometheus-stack = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "kube-prometheus-stack")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "kube-prometheus-stack")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "kube-prometheus-stack")], "version", null)
  }
  grafana_password         = random_string.grafana_password.result
  grafana_domain_name      = "grafana-${local.domain_suffix}"
  prometheus_domain_name   = "prometheus-${local.domain_suffix}"
  alertmanager_domain_name = "alertmanager-${local.domain_suffix}"

  kube_prometheus_stack_template = templatefile("${path.module}/templates/prometheus-values.yaml",
    {
      prometheus_domain_name     = local.prometheus_domain_name
      alertmanager_domain_name   = local.alertmanager_domain_name
      ip_whitelist               = local.ip_whitelist
      default_region             = local.region
      grafana_domain_name        = local.grafana_domain_name
      grafana_password           = local.grafana_password
      role_arn                   = module.aws_iam_grafana.role_arn
      gitlab_client_id           = local.grafana_gitlab_client_id
      gitlab_client_secret       = local.grafana_gitlab_client_secret
      gitlab_group               = local.grafana_gitlab_group
      alertmanager_slack_url     = local.alertmanager_slack_url
      alertmanager_slack_channel = local.alertmanager_slack_channel
  })
}

resource "random_string" "grafana_password" {
  length  = 20
  special = true
}

resource "helm_release" "prometheus_operator" {
  name        = "kube-prometheus-stack"
  chart       = local.kube-prometheus-stack.chart
  repository  = local.kube-prometheus-stack.repository
  version     = local.kube-prometheus-stack.chart_version
  namespace   = module.monitoring_namespace.name
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    local.kube_prometheus_stack_template
  ]
}

module "aws_iam_grafana" {
  source = "../modules/aws-iam-eks-trusted"

  name              = "${local.name}-grafana"
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowReadingMetricsFromCloudWatch",
        "Effect" : "Allow",
        "Action" : [
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:GetMetricData"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowReadingTagsInstancesRegionsFromEC2",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeTags",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowReadingResourcesForTags",
        "Effect" : "Allow",
        "Action" : "tag:GetResources",
        "Resource" : "*"
      }
    ]
  })
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
