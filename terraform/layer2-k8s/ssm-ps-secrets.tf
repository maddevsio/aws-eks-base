locals {
  kibana_gitlab_client_id      = data.aws_ssm_parameter.kibana_gitlab_client_id.value
  kibana_gitlab_client_secret  = data.aws_ssm_parameter.kibana_gitlab_client_secret.value
  grafana_gitlab_client_id     = data.aws_ssm_parameter.grafana_gitlab_client_id.value
  grafana_gitlab_client_secret = data.aws_ssm_parameter.grafana_gitlab_client_secret.value
  gitlab_registration_token    = data.aws_ssm_parameter.gitlab_registration_token.value
  alertmanager_slack_url       = data.aws_ssm_parameter.alertmanager_slack_url
}

data "aws_ssm_parameter" "kibana_gitlab_client_id" {
  name = "/${local.name_wo_region}/infra/kibana/gitlab_client_id"
}

data "aws_ssm_parameter" "kibana_gitlab_client_secret" {
  name = "/${local.name_wo_region}/infra/kibana/gitlab_client_secret"
}

data "aws_ssm_parameter" "grafana_gitlab_client_id" {
  name = "/${local.name_wo_region}/infra/grafana/gitlab_client_id"
}

data "aws_ssm_parameter" "grafana_gitlab_client_secret" {
  name = "/${local.name_wo_region}/infra/grafana/gitlab_client_secret"
}

data "aws_ssm_parameter" "gitlab_registration_token" {
  name = "/${local.name_wo_region}/infra/runner/gitlab_registration_token"
}

data "aws_ssm_parameter" "alertmanager_slack_url" {
  name = "/${local.name_wo_region}/infra/alertmanager/slack_url"
}


