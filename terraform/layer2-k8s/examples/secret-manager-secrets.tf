locals {
  kibana_gitlab_client_id      = jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string)["kibana_gitlab_client_id"]
  kibana_gitlab_client_secret  = jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string)["kibana_gitlab_client_secret"]
  grafana_gitlab_client_id     = jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string)["grafana_gitlab_client_id"]
  grafana_gitlab_client_secret = jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string)["grafana_gitlab_client_secret"]
  gitlab_registration_token    = jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string)["gitlab_registration_token"]

}

data "aws_secretsmanager_secret" "infra" {
  name = "/${local.name_wo_region}/infra/gitlab-tokens"
}

data "aws_secretsmanager_secret_version" "infra" {
  secret_id = data.aws_secretsmanager_secret.infra.id
}






