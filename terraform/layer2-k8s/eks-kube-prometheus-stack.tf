locals {
  kube_prometheus_stack = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "kube-prometheus-stack")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "kube-prometheus-stack")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "kube-prometheus-stack")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "kube-prometheus-stack")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "kube-prometheus-stack")].version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "kube-prometheus-stack")].namespace
  }
  grafana_password         = local.kube_prometheus_stack.enabled ? random_string.grafana_password[0].result : "test123"
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
      role_arn                   = local.kube_prometheus_stack.enabled ? module.aws_iam_grafana[0].role_arn : ""
      gitlab_client_id           = local.grafana_gitlab_client_id
      gitlab_client_secret       = local.grafana_gitlab_client_secret
      gitlab_group               = local.grafana_gitlab_group
      alertmanager_slack_url     = local.alertmanager_slack_url
      alertmanager_slack_channel = local.alertmanager_slack_channel
  })
}

#tfsec:ignore:kubernetes-network-no-public-egress tfsec:ignore:kubernetes-network-no-public-ingress
module "monitoring_namespace" {
  count = local.kube_prometheus_stack.enabled ? 1 : 0

  source = "../modules/kubernetes-namespace"
  name   = local.kube_prometheus_stack.namespace
  network_policies = [
    {
      name         = "default-deny"
      policy_types = ["Ingress", "Egress"]
      pod_selector = {}
    },
    {
      name         = "allow-this-namespace"
      policy_types = ["Ingress"]
      pod_selector = {}
      ingress = {
        from = [
          {
            namespace_selector = {
              match_labels = {
                name = local.kube_prometheus_stack.namespace
              }
            }
          }
        ]
      }
    },
    {
      name         = "allow-ingress"
      policy_types = ["Ingress"]
      pod_selector = {}
      ingress = {

        from = [
          {
            namespace_selector = {
              match_labels = {
                name = local.ingress_nginx.namespace
              }
            }
          }
        ]
      }
    },
    {
      name         = "allow-control-plane"
      policy_types = ["Ingress"]
      pod_selector = {
        match_expressions = {
          key      = "app"
          operator = "In"
          values   = ["${local.kube_prometheus_stack.name}-operator"]
        }
      }
      ingress = {
        ports = [
          {
            port     = "10250"
            protocol = "TCP"
          }
        ]
        from = [
          {
            ip_block = {
              cidr = "0.0.0.0/0"
            }
          }
        ]
      }
    },
    {
      name         = "allow-egress"
      policy_types = ["Egress"]
      pod_selector = {}
      egress = {
        to = [
          {
            ip_block = {
              cidr = "0.0.0.0/0"
              except = [
                "169.254.169.254/32"
              ]
            }
          }
        ]
      }
    }
  ]
}

module "aws_iam_grafana" {
  count = local.kube_prometheus_stack.enabled ? 1 : 0

  source            = "../modules/aws-iam-eks-trusted"
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

resource "random_string" "grafana_password" {
  count   = local.kube_prometheus_stack.enabled ? 1 : 0
  length  = 20
  special = true
}

resource "helm_release" "prometheus_operator" {
  count = local.kube_prometheus_stack.enabled ? 1 : 0

  name        = local.kube_prometheus_stack.name
  chart       = local.kube_prometheus_stack.chart
  repository  = local.kube_prometheus_stack.repository
  version     = local.kube_prometheus_stack.chart_version
  namespace   = module.monitoring_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    local.kube_prometheus_stack_template
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

output "get_grafana_admin_password" {
  value       = "kubectl get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 --decode ; echo"
  description = "Command which gets admin password from kubernetes secret"
}
