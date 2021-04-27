locals {
  gitlab_runner_cache_bucket_name = data.terraform_remote_state.layer1-aws.outputs.gitlab_runner_cache_bucket_name

  gitlab_runner_template = templatefile("${path.module}/templates/gitlab-runner-values.tmpl",
    {
      registration_token = local.gitlab_registration_token
      namespace          = kubernetes_namespace.ci.id
      role_arn           = module.aws_iam_gitlab_runner.role_arn
      runner_sa          = module.eks_rbac_gitlab_runner.sa_name
      bucket_name        = local.gitlab_runner_cache_bucket_name
      region             = local.region
  })

}

module "aws_iam_gitlab_runner" {
  source = "../modules/aws-iam-ci"

  name              = local.name
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
  eks_cluster_id    = local.eks_cluster_id
  s3_bucket_name    = local.gitlab_runner_cache_bucket_name
}

module "eks_rbac_gitlab_runner" {
  source = "../modules/eks-rbac-ci"

  name      = "${local.name}-gl"
  role_arn  = module.aws_iam_gitlab_runner.role_arn
  namespace = kubernetes_namespace.ci.id
}

resource "helm_release" "gitlab_runner" {
  name        = "gitlab-runner"
  chart       = "gitlab-runner"
  repository  = local.helm_repo_gitlab
  version     = var.gitlab_runner_version
  namespace   = kubernetes_namespace.ci.id
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    local.gitlab_runner_template
  ]
}



