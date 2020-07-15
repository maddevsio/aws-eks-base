module "aws_iam_grafana" {
  source = "../modules/aws-iam-grafana"

  name              = local.name
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
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
    gitlab_client_id         = var.grafana_gitlab_client_id
    gitlab_client_secret     = var.grafana_gitlab_client_secret
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
