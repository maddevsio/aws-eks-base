locals {
  logstash = merge(
    local.helm_releases[index(local.helm_releases.*.id, "logstash")],
  var.logstash)
}

data "template_file" "logstash" {
  template = file("${path.module}/elk-templates/logstash-values.yaml")
  vars = {
    env = "${local.env}"
  }
}

resource "helm_release" "logstash" {
  count = local.logstash.enabled ? 1 : 0

  name        = "logstash"
  chart       = "logstash"
  repository  = local.logstash.repository
  version     = local.logstash.chart_version

  namespace   = "elk"
  timeout     = "600"
  max_history = var.helm_release_history_size

  values = compact(
    [data.template_file.logstash.rendered,
      try(local.logstash.helm_values_override, null),
  ])
}

resource "kubectl_manifest" "elk_external_secrets" {
  count = local.logstash.enabled ? 1 : 0
  yaml_body = <<-EOF
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: elastic-credentials
      namespace: elk
    spec:
      refreshInterval: 1m
      secretStoreRef:
        name: elastic-credentials
        kind: SecretStore
      target:
        name: elastic-credentials
        creationPolicy: Owner
      dataFrom:
        - extract:
            key: "/${var.name}/infra/elk"
    EOF
  depends_on = [
    helm_release.external_secrets
  ]
}

resource "kubectl_manifest" "elk_secretstore" {
  count = local.logstash.enabled ? 1 : 0
  yaml_body = <<-EOF
    apiVersion: external-secrets.io/v1beta1
    kind: SecretStore
    metadata:
      name: elastic-credentials
      namespace: elk
    spec:
      provider:
        aws:
          service: SecretsManager
          region: us-east-1
          auth:
            jwt:
              serviceAccountRef:
                name: sa-filebeat
    EOF
  depends_on = [
    helm_release.external_secrets
  ]
}

resource "kubectl_manifest" "kibana_service_account" {
  count = local.logstash.enabled ? 1 : 0
  yaml_body = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      annotations:
        eks.amazonaws.com/role-arn: ${aws_iam_role.elk_service_account_role[count.index].arn}
      name: sa-filebeat
      namespace: elk
    EOF
  depends_on = [
    aws_iam_role.elk_service_account_role
  ]
}

resource "aws_iam_role" "elk_service_account_role" {
  count              = local.logstash.enabled ? 1 : 0
  name               = "elk-service-account-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${var.eks_oidc_provider_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.${var.region}.amazonaws.com/id/${regex("[A-Z0-9]{32}", var.eks_oidc_provider_arn)}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "elk_secret_manager_policy" {
  count = local.logstash.enabled ? 1 : 0
  name  = "elk-secret-manager-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:UpdateSecret",
          "secretsmanager:PutSecretValue"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:/${var.name}/infra/elk*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "elk_secret_manager_policy_attachment" {
  count      = local.logstash.enabled ? 1 : 0
  name       = "elk-secret-manager-policy-attachment"
  roles      = [aws_iam_role.elk_service_account_role[count.index].name]
  policy_arn = aws_iam_policy.elk_secret_manager_policy[count.index].arn
}
