locals {
  kibana_gitlab_client_id      = jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string)["kibana_gitlab_client_id"]
  kibana_gitlab_client_secret  = jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string)["kibana_gitlab_client_secret"]
  kibana_gitlab_group          = jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string)["kibana_gitlab_group"]
  grafana_gitlab_client_id     = jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string)["grafana_gitlab_client_id"]
  grafana_gitlab_client_secret = jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string)["grafana_gitlab_client_secret"]
  gitlab_registration_token    = jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string)["gitlab_registration_token"]
  grafana_gitlab_group         = jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string)["grafana_gitlab_group"]
  alertmanager_slack_url       = jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string)["alertmanager_slack_url"]
  alertmanager_slack_channel   = jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string)["alertmanager_slack_channel"]
}

data "aws_secretsmanager_secret" "infra" {
  name = "/${local.name_wo_region}/infra/layer2-k8s"
}

data "aws_secretsmanager_secret_version" "infra" {
  secret_id = data.aws_secretsmanager_secret.infra.id
}
