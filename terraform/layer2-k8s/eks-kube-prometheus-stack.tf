locals {
  kube_prometheus_stack = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "kube-prometheus-stack")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "kube-prometheus-stack")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "kube-prometheus-stack")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "kube-prometheus-stack")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "kube-prometheus-stack")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "kube-prometheus-stack")].namespace
  }
  grafana_password             = local.kube_prometheus_stack.enabled ? random_string.grafana_password[0].result : "test123"
  grafana_domain_name          = "grafana-${local.domain_suffix}"
  prometheus_domain_name       = "prometheus-${local.domain_suffix}"
  alertmanager_domain_name     = "alertmanager-${local.domain_suffix}"
  kube_prometheus_stack_values = <<VALUES
# Prometheus Server parameters
prometheus:
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      nginx.ingress.kubernetes.io/whitelist-source-range: ${local.ip_whitelist}
    path: /
    hosts:
      - ${local.prometheus_domain_name}
    tls:
    - hosts:
      - ${local.prometheus_domain_name}
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: advanced
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 30Gi
    resources:
      requests:
        cpu: 200m
        memory: 1024Mi
      limits:
        cpu: 400m
        memory: 1024Mi
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: eks.amazonaws.com/capacityType
              operator: In
              values:
                - ON_DEMAND

prometheusOperator:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: eks.amazonaws.com/capacityType
            operator: In
            values:
              - ON_DEMAND
VALUES

  kube_prometheus_stack_grafana_values = <<VALUES
# Grafana settings
grafana:
  enabled: true
  image:
    tag: 7.2.0
  deploymentStrategy:
    type: Recreate
  adminPassword: "${local.grafana_password}"
  serviceAccount:
    annotations:
      "eks.amazonaws.com/role-arn": ${local.kube_prometheus_stack.enabled ? module.aws_iam_grafana[0].role_arn : ""}
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    path: /
    hosts:
      - ${local.grafana_domain_name}
    tls:
    - hosts:
      - ${local.grafana_domain_name}
  env:
    # all values must be quoted
    GF_SERVER_ROOT_URL: "https://${local.grafana_domain_name}"
    GF_USERS_ALLOW_SIGN_UP: "false"
    GF_AUTH_GITLAB_ENABLED: "true"
    GF_AUTH_GITLAB_ALLOW_SIGN_UP: "true"
    GF_AUTH_GITLAB_CLIENT_ID: "${local.grafana_gitlab_client_id}"
    GF_AUTH_GITLAB_CLIENT_SECRET: "${local.grafana_gitlab_client_secret}"
    GF_AUTH_GITLAB_SCOPES: "read_api"
    GF_AUTH_GITLAB_AUTH_URL: "https://gitlab.com/oauth/authorize"
    GF_AUTH_GITLAB_TOKEN_URL: "https://gitlab.com/oauth/token"
    GF_AUTH_GITLAB_API_URL: "https://gitlab.com/api/v4"
    GF_AUTH_GITLAB_ALLOWED_GROUPS: "${local.grafana_gitlab_group}"

  persistence:
    enabled: false

  sidecar:
    datasources:
      enabled: true

  datasources:
    datasources.yaml:
      apiVersion: 1
      datasources:
        - name: CloudWatch
          type: cloudwatch
          jsonData:
            authType: credentials
            defaultRegion: "${local.region}"
        - name: Loki
          type: loki
          url: http://loki-stack.loki:3100
          jsonData:
            maxLines: 1000

  dashboardProviders:
    dashboardproviders.yaml:
      apiVersion: 1
      providers:
      - name: 'logs'
        orgId: 1
        folder: 'logs'
        type: file
        disableDeletion: true
        editable: true
        options:
          path: /var/lib/grafana/dashboards/logs
      - name: 'k8s'
        orgId: 1
        folder: 'k8s'
        type: file
        disableDeletion: true
        editable: true
        options:
          path: /var/lib/grafana/dashboards/k8s

  dashboards:
    logs:
      logs:
        ## Dashboard for quick search application logs for loki with two datasources loki and prometheus - https://grafana.com/grafana/dashboards/12019
        url: https://grafana-dashboards.maddevs.org/common/aws-eks-base/loki-dashboard-quick-search.json

    k8s:
      nginx-ingress:
      ## Dashboard for nginx-ingress metrics - https://grafana.com/grafana/dashboards/9614
        gnetId: 9614
        datasource: Prometheus
      loki-promtail:
      ## Dashboard for loki and promtail metrics - https://grafana.com/grafana/dashboards/10880
        gnetId: 10880
        datasource: Prometheus
      cluster-autoscaler:
      ## Dashboard for cluster-autoscaler metrics - https://grafana.com/grafana/dashboards/3831
        gnetId: 3831
        datasource: Prometheus

  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: eks.amazonaws.com/capacityType
            operator: In
            values:
              - SPOT
VALUES

  kube_prometheus_stack_alertmanager_values = <<VALUES
# Alertmanager parameters
alertmanager:
  enabled: false
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      nginx.ingress.kubernetes.io/whitelist-source-range: ${local.ip_whitelist}
    path: /
    hosts:
      - ${local.alertmanager_domain_name}
    tls:
    - hosts:
      - ${local.alertmanager_domain_name}
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          storageClassName: advanced
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi
  config:
    global:
      resolve_timeout: 5m
      slack_api_url: ${local.alertmanager_slack_url}
    route:
      group_by: ['job']
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 12h
      receiver: 'null'
      routes:
        - match:
            alertname: Watchdog
          receiver: 'null'
        - match:
          receiver: "slack-notifications"
          continue: true
    receivers:
    - name: 'null'
    - name: 'slack-notifications'
      slack_configs:
        - channel: ${local.alertmanager_slack_channel}
          send_resolved: true
          icon_url: https://avatars3.githubusercontent.com/u/3380462
          username: 'AlertManager'
          color: '{{ if eq .Status "firing" }}danger{{ else }}good{{ end }}'
          title: '[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .GroupLabels.SortedPairs.Values | join " " }} {{ if gt (len .CommonLabels) (len .GroupLabels) }}({{ with .CommonLabels.Remove .GroupLabels.Names }}{{ .Values | join " " }}{{ end }}){{ end }}'
          text: |-
            {{ range .Alerts }}
            {{ if .Annotations.summary }}*Alert:*  - {{ .Annotations.summary }} - `{{ .Labels.severity }}`{{ end }}
            *Description:* {{ .Annotations.message }}
            *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
            {{ end }}
          icon_emoji: '{{ template "slack.default.iconemoji" . }}'

  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: eks.amazonaws.com/capacityType
                operator: In
                values:
                  - ON_DEMAND
VALUES
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
    local.kube_prometheus_stack_values,
    local.kube_prometheus_stack_grafana_values,
    local.kube_prometheus_stack_alertmanager_values
  ]

}

output "grafana_domain_name" {
  value       = local.kube_prometheus_stack.enabled ? local.grafana_domain_name : null
  description = "Grafana dashboards address"
}

output "alertmanager_domain_name" {
  value       = local.kube_prometheus_stack.enabled ? local.alertmanager_domain_name : null
  description = "Alertmanager ui address"
}

output "prometheus_domain_name" {
  value       = local.kube_prometheus_stack.enabled ? local.prometheus_domain_name : null
  description = "Prometheus ui address"
}

output "grafana_admin_password" {
  value       = local.kube_prometheus_stack.enabled ? local.grafana_password : null
  sensitive   = true
  description = "Grafana admin password"
}

output "get_grafana_admin_password" {
  value       = local.kube_prometheus_stack.enabled ? "kubectl get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 --decode ; echo" : null
  description = "Command which gets admin password from kubernetes secret"
}
