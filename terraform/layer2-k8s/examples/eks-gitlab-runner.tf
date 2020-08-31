module "aws_iam_gitlab_runner" {
  source = "../modules/aws-iam-gitlab-runner"

  name              = local.name
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
  eks_cluster_id    = local.eks_cluster_id
}

module "eks_rbac_gitlab_runner" {
  source = "../modules/eks-rbac-ci"

  name             = "${local.name}-gl"
  role_arn         = module.aws_iam_gitlab_runner.role_arn
  runner_namespace = kubernetes_namespace.ci.id
}

data "template_file" "gitlab_runner" {
  template = "${file("${path.module}/templates/gitlab-runner-values.yaml")}"

  vars = {
    registration_token = var.gitlab_registration_token
    namespace          = kubernetes_namespace.ci.id
    role_arn           = module.aws_iam_gitlab_runner.role_arn
    runner_sa          = module.eks_rbac_gitlab_runner.sa_name
  }
}

resource "helm_release" "gitlab_runner" {
  name       = "gitlab-runner"
  chart      = "gitlab-runner"
  repository = local.helm_repo_gitlab
  namespace  = kubernetes_namespace.ci.id
  version    = var.gitlab_runner_version
  wait       = false

  values = [
    "${data.template_file.gitlab_runner.rendered}",
  ]
}
