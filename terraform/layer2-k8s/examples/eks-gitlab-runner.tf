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
}

module "eks_rbac_gitlab_runner" {
  source = "../modules/eks-rbac-ci"

  name             = "${local.name}-gl"
  role_arn         = module.aws_iam_gitlab_runner.role_arn
  runner_namespace = kubernetes_namespace.ci.id
}

module "aws_iam_gitlab_runner_cache_s3" {
  source = "../modules/aws-iam-s3"

  name              = "${local.name}-gl-cache"
  region            = local.region
  bucket_name       = local.gitlab_runner_cache_bucket_name
  oidc_provider_arn = local.eks_oidc_provider_arn
  create_user       = true
}

resource "helm_release" "gitlab_runner" {
  name       = "gitlab-runner"
  chart      = "gitlab-runner"
  repository = local.helm_repo_gitlab
  namespace  = kubernetes_namespace.ci.id
  version    = var.gitlab_runner_version
  wait       = false

  values = [
    local.gitlab_runner_template
  ]
}

resource "kubernetes_secret" "gitlab_runner_cache_s3_user_creds" {
  metadata {
    name      = "s3access"
    namespace = kubernetes_namespace.ci.id
  }

  data = {
    "accesskey" = module.aws_iam_gitlab_runner_cache_s3.access_key_id
    "secretkey" = module.aws_iam_gitlab_runner_cache_s3.access_secret_key
  }
}

