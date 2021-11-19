locals {
  kibana_gitlab_client_id     = lookup(jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string), "kibana_gitlab_client_id", "mock_value")
  kibana_gitlab_client_secret = lookup(jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string), "kibana_gitlab_client_secret", "mock_value")
  kibana_gitlab_group         = lookup(jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string), "kibana_gitlab_group", "mock_value")
  gitlab_registration_token   = lookup(jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string), "gitlab_registration_token", "mock_value")
  alertmanager_slack_url      = lookup(jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string), "alertmanager_slack_url", "mock_value")
  alertmanager_slack_channel  = lookup(jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string), "alertmanager_slack_channel", "mock_value")
}

data "aws_secretsmanager_secret" "infra" {
  name = "/${local.name_wo_region}/infra/layer2-k8s"
}

data "aws_secretsmanager_secret_version" "infra" {
  secret_id = data.aws_secretsmanager_secret.infra.id
}
