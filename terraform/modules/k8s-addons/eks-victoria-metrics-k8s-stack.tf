locals {
  victoria_metrics_k8s_stack = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "vm-k8s-stack")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "vm-k8s-stack")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "vm-k8s-stack")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "vm-k8s-stack")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "vm-k8s-stack")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "vm-k8s-stack")].namespace
  }
  victoria_metrics_k8s_stack_grafana_oauth_type                   = "" # we support three options: without ouath (empty value), github or gitlab. Default is empty
  victoria_metrics_k8s_stack_grafana_password                     = local.victoria_metrics_k8s_stack.enabled ? random_string.victoria_metrics_k8s_stack_grafana_password[0].result : ""
  victoria_metrics_k8s_stack_grafana_gitlab_client_id             = lookup(jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string), "grafana_gitlab_client_id", "")
  victoria_metrics_k8s_stack_grafana_gitlab_client_secret         = lookup(jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string), "grafana_gitlab_client_secret", "")
  victoria_metrics_k8s_stack_grafana_gitlab_group                 = lookup(jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string), "grafana_gitlab_group", "")
  victoria_metrics_k8s_stack_grafana_github_client_id             = lookup(jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string), "grafana_github_client_id", "")
  victoria_metrics_k8s_stack_grafana_github_client_secret         = lookup(jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string), "grafana_github_client_secret", "")
  victoria_metrics_k8s_stack_grafana_github_team_ids              = lookup(jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string), "grafana_github_team_ids", "")
  victoria_metrics_k8s_stack_grafana_github_allowed_organizations = lookup(jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string), "grafana_github_allowed_organizations", "")
  victoria_metrics_k8s_stack_alertmanager_slack_webhook           = lookup(jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string), "alertmanager_slack_webhook", "")
  victoria_metrics_k8s_stack_alertmanager_slack_channel           = lookup(jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string), "alertmanager_slack_channel", "")
  victoria_metrics_k8s_stack_grafana_domain_name                  = "grafana-${local.domain_suffix}"
  victoria_metrics_k8s_stack_alertmanager_domain_name             = "alertmanager-${local.domain_suffix}"
  victoria_metrics_k8s_stack_values                               = <<VALUES
defaultRules:
  create: true
  groups:
    general:
      create: false
    kubernetesSystem:
      create: false

defaultDashboards:
  enabled: true

victoria-metrics-operator:
  enabled: true
  crds:
    plain: true
    cleanup:
      enabled: true
  operator:
    disable_prometheus_converter: false
    enable_converter_ownership: true
    useCustomConfigReloader: true

vmsingle:
  enabled: true
  spec:
    port: "8429"
    retentionPeriod: "14"
    replicaCount: 1
    extraArgs: {}
    storage:
      storageClassName: advanced
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 30Gi
    resources:
      limits:
        cpu: "400m"
        memory: "1024Mi"
      requests:
        cpu: "200m"
        memory: "1024Mi"
    extraArgs:
      maxLabelsPerTimeseries: "50"
      search.maxConcurrentRequests: "8"
      search.maxQueryDuration: "10s"
      memory.allowedPercent: "80"
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: karpenter.sh/capacity-type
              operator: In
              values:
                - on-demand

vmagent:
  enabled: true
  spec:
    port: "8429"
    selectAllByDefault: true
    scrapeInterval: 20s
    extraArgs:
      promscrape.streamParse: "true"
      promscrape.dropOriginalLabels: "true"
      promscrape.maxScrapeSize: "335544320"
    resources:
      limits:
        cpu: "200m"
        memory: "128Mi"
      requests:
        cpu: "100m"
        memory: "128Mi"
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: karpenter.sh/capacity-type
              operator: In
              values:
                - on-demand

vmalert:
  enabled: true
  remoteWriteVMAgent: false
  spec:
    port: "8080"
    selectAllByDefault: true
    evaluationInterval: 15s
    extraArgs:
      http.pathPrefix: "/"
      notifier.blackhole: "true"
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: karpenter.sh/capacity-type
              operator: In
              values:
                - on-demand

kube-state-metrics:
  enabled: false
kubelet:
  enabled: false
kubeApiServer:
  enabled: false
kubeControllerManager:
  enabled: false
kubeDns:
  enabled: false
coreDns:
  enabled: false
kubeEtcd:
  enabled: false
kubeScheduler:
  enabled: false
kubeProxy:
  enabled: false
prometheus-operator-crds:
  enabled: false
extraObjects: []
VALUES
  victoria_metrics_k8s_stack_grafana_values                       = <<VALUES
# Grafana settings
grafana:
  enabled: true
  adminPassword: "${local.victoria_metrics_k8s_stack_grafana_password}"
  serviceAccount:
    annotations:
      "eks.amazonaws.com/role-arn": ${local.victoria_metrics_k8s_stack.enabled ? module.aws_iam_victoria_metrics_k8s_stack_grafana[0].role_arn : ""}
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    path: /
    hosts:
      - ${local.victoria_metrics_k8s_stack_grafana_domain_name}
    tls:
    - hosts:
      - ${local.victoria_metrics_k8s_stack_grafana_domain_name}
  env:
    GF_SERVER_ROOT_URL: https://${local.victoria_metrics_k8s_stack_grafana_domain_name}
    GF_USERS_ALLOW_SIGN_UP: false
  datasources:
    datasources.yaml:
      apiVersion: 1
      datasources:
      - name: CloudWatch
        type: cloudwatch
        jsonData:
          authType: default
          assumeRoleArn:
          defaultRegion: "${var.region}"
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
      - name: 'istio'
        orgId: 1
        folder: 'istio'
        type: file
        disableDeletion: true
        editable: true
        options:
          path: /var/lib/grafana/dashboards/istio

  dashboards:
    logs:
      logs:
        ## Dashboard for quick search application logs for loki with two datasources loki and prometheus - https://grafana.com/grafana/dashboards/12019
        url: https://grafana-dashboards.maddevs.org/common/aws-eks-base/loki-dashboard-quick-search.json
    k8s:
      nginx-ingress:
        gnetId: 9614
        datasource: VictoriaMetrics
      loki-promtail:
        gnetId: 10880
        datasource: VictoriaMetrics
      cluster-autoscaler:
        gnetId: 3831
        datasource: VictoriaMetrics

  sidecar:
    datasources:
      enabled: true
      initDatasources: true
      default:
        - name: VictoriaMetrics
          isDefault: true
    dashboards:
      enabled: false
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: karpenter.sh/capacity-type
            operator: In
            values:
              - spot
VALUES
  victoria_metrics_k8s_stack_grafana_istio_values                 = <<VALUES
grafana:
  dashboards:
    istio:
      Istio-control-plane:
        gnetId: 7645
        revision: 101
        datasource: VictoriaMetrics
      Istio-galley:
        gnetId: 7648
        revision: 3
        datasource: VictoriaMetrics
      Istio-mesh:
        gnetId: 7639
        revision: 101
        datasource: VictoriaMetrics
      Istio-service:
        gnetId: 7636
        revision: 101
        datasource: VictoriaMetrics
      Istio-workload:
        gnetId: 7630
        revision: 101
        datasource: VictoriaMetrics
VALUES
  victoria_metrics_k8s_stack_grafana_gitlab_oauth_values          = <<VALUES
grafana:
  env:
    GF_AUTH_GITLAB_ENABLED: true
    GF_AUTH_GITLAB_ALLOW_SIGN_UP: true
    GF_AUTH_GITLAB_CLIENT_ID: ${local.victoria_metrics_k8s_stack_grafana_gitlab_client_id}
    GF_AUTH_GITLAB_CLIENT_SECRET: ${local.victoria_metrics_k8s_stack_grafana_gitlab_client_secret}
    GF_AUTH_GITLAB_SCOPES: read_api
    GF_AUTH_GITLAB_AUTH_URL: https://gitlab.com/oauth/authorize
    GF_AUTH_GITLAB_TOKEN_URL: https://gitlab.com/oauth/token
    GF_AUTH_GITLAB_API_URL: https://gitlab.com/api/v4
    GF_AUTH_GITLAB_ALLOWED_GROUPS: ${local.victoria_metrics_k8s_stack_grafana_gitlab_group}
VALUES
  victoria_metrics_k8s_stack_grafana_github_oauth_values          = <<VALUES
grafana:
  env:
    GF_AUTH_GITHUB_ENABLED: true
    GF_AUTH_GITHUB_ALLOW_SIGN_UP: true
    GF_AUTH_GITHUB_CLIENT_ID: ${local.victoria_metrics_k8s_stack_grafana_github_client_id}
    GF_AUTH_GITHUB_CLIENT_SECRET: ${local.victoria_metrics_k8s_stack_grafana_github_client_secret}
    GF_AUTH_GITHUB_SCOPES: user:email,read:org
    GF_AUTH_GITHUB_AUTH_URL: https://github.com/login/oauth/authorize
    GF_AUTH_GITHUB_TOKEN_URL: https://github.com/login/oauth/access_token
    GF_AUTH_GITHUB_API_URL: https://api.github.com/user
    GF_AUTH_GITHUB_TEAM_IDS: ${local.victoria_metrics_k8s_stack_grafana_github_team_ids}
    GF_AUTH_GITHUB_ALOWED_ORGANISATIONS: ${local.victoria_metrics_k8s_stack_grafana_github_allowed_organizations}
VALUES
  victoria_metrics_k8s_stack_alertmanager_values                  = <<VALUES
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
      - ${local.victoria_metrics_k8s_stack_alertmanager_domain_name}
    tls:
    - hosts:
      - ${local.victoria_metrics_k8s_stack_alertmanager_domain_name}
  spec:
    storage:
      volumeClaimTemplate:
        spec:
          storageClassName: advanced
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
  config:
    global:
      resolve_timeout: 5m
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
    receivers:
    - name: 'null'

  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: karpenter.sh/capacity-type
                operator: In
                values:
                  - on-demand
VALUES
  victoria_metrics_k8s_stack_alertmanager_slack_values            = <<VALUES
# Alertmanager parameters
alertmanager:
  config:
    global:
      slack_api_url: ${local.victoria_metrics_k8s_stack_alertmanager_slack_webhook}
    route:
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
        - channel: ${local.victoria_metrics_k8s_stack_alertmanager_slack_channel}
          send_resolved: true
          icon_url: https://avatars3.githubusercontent.com/u/3380462
          title: |-
            [{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .CommonLabels.alertname }} for {{ .CommonLabels.job }}
            {{- if gt (len .CommonLabels) (len .GroupLabels) -}}
              {{" "}}(
              {{- with .CommonLabels.Remove .GroupLabels.Names }}
                {{- range $index, $label := .SortedPairs -}}
                  {{ if $index }}, {{ end }}
                  {{- $label.Name }}="{{ $label.Value -}}"
                {{- end }}
              {{- end -}}
              )
            {{- end }}
          text: >-
            {{ range .Alerts -}}
            *Alert:* {{ .Annotations.title }}{{ if .Labels.severity }} - `{{ .Labels.severity }}`{{ end }}

            *Description:* {{ .Annotations.description }}  {{ .Annotations.message }}

            *Details:*
              {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
              {{ end }}
            {{ end }}
VALUES
}

module "victoria_metrics_k8s_stack_namespace" {
  count = local.victoria_metrics_k8s_stack.enabled ? 1 : 0

  source = "../eks-kubernetes-namespace"
  name   = local.victoria_metrics_k8s_stack.namespace
}

module "aws_iam_victoria_metrics_k8s_stack_grafana" {
  count = local.victoria_metrics_k8s_stack.enabled ? 1 : 0

  source            = "../aws-iam-eks-trusted"
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
          "cloudwatch:GetMetricData",
          "logs:DescribeLogGroups"
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

resource "random_string" "victoria_metrics_k8s_stack_grafana_password" {
  count   = local.victoria_metrics_k8s_stack.enabled ? 1 : 0
  length  = 20
  special = true
}

resource "helm_release" "victoria_metrics_k8s_stack" {
  count = local.victoria_metrics_k8s_stack.enabled ? 1 : 0

  name        = local.victoria_metrics_k8s_stack.name
  chart       = local.victoria_metrics_k8s_stack.chart
  repository  = local.victoria_metrics_k8s_stack.repository
  version     = local.victoria_metrics_k8s_stack.chart_version
  namespace   = module.victoria_metrics_k8s_stack_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = compact([
    local.victoria_metrics_k8s_stack_values,
    local.victoria_metrics_k8s_stack_grafana_values,
    local.istio.enabled ? local.victoria_metrics_k8s_stack_grafana_istio_values : null,
    local.victoria_metrics_k8s_stack_grafana_oauth_type == "gitlab" ? local.victoria_metrics_k8s_stack_grafana_gitlab_oauth_values : null,
    local.victoria_metrics_k8s_stack_grafana_oauth_type == "github" ? local.victoria_metrics_k8s_stack_grafana_github_oauth_values : null,
    local.victoria_metrics_k8s_stack_alertmanager_values,
    local.victoria_metrics_k8s_stack_alertmanager_slack_webhook != "" ? local.victoria_metrics_k8s_stack_alertmanager_slack_values : null
  ])

  depends_on = [
    kubectl_manifest.kube_prometheus_stack_operator_crds,
    helm_release.ingress_nginx
  ]

}

output "victoria_metrics_k8s_stack_grafana_domain_name" {
  value       = local.victoria_metrics_k8s_stack.enabled ? local.victoria_metrics_k8s_stack_grafana_domain_name : null
  description = "Grafana dashboards address"
}

output "victoria_metrics_k8s_stack_grafana_admin_password" {
  value       = local.victoria_metrics_k8s_stack.enabled ? local.victoria_metrics_k8s_stack_grafana_password : null
  sensitive   = true
  description = "Grafana admin password"
}

output "victoria_metrics_k8s_stack_get_grafana_admin_password" {
  value       = local.victoria_metrics_k8s_stack.enabled ? "kubectl get secrets -n ${local.victoria_metrics_k8s_stack.namespace} victoria-metrics-k8s-stack-grafana -o jsonpath='{.data.admin-password}' | base64 --decode; echo" : null
  description = "Command which gets admin password from kubernetes secret"
}
