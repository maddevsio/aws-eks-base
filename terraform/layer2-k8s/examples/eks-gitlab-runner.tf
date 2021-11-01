locals {
  gitlab_runner_cache_bucket_name = data.terraform_remote_state.layer1-aws.outputs.gitlab_runner_cache_bucket_name

  gitlab_runner_template = templatefile("${path.module}/templates/gitlab-runner-values.tmpl",
    {
      registration_token = local.gitlab_registration_token
      namespace          = module.ci_namespace.name
      role_arn           = module.aws_iam_gitlab_runner.role_arn
      runner_sa          = module.eks_rbac_gitlab_runner.sa_name
      bucket_name        = local.gitlab_runner_cache_bucket_name
      region             = local.region
  })

}

module "eks_rbac_gitlab_runner" {
  source = "../modules/eks-rbac-ci"

  name      = "${local.name}-gl"
  role_arn  = module.aws_iam_gitlab_runner.role_arn
  namespace = module.ci_namespace.name
}

resource "helm_release" "gitlab_runner" {
  name        = "gitlab-runner"
  chart       = "gitlab-runner"
  repository  = local.helm_repo_gitlab
  version     = var.gitlab_runner_version
  namespace   = module.ci_namespace.name
  wait        = false
  max_history = var.helm_release_history_size

  values = [
    local.gitlab_runner_template
  ]
}

module "aws_iam_gitlab_runner" {
  source = "../modules/aws-iam-eks-trusted"

  name              = "${local.name}-ci"
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:*",
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:*"
        ],
        "Resource" : [
          "arn:aws:s3:::${local.gitlab_runner_cache_bucket_name}",
          "arn:aws:s3:::${local.gitlab_runner_cache_bucket_name}/*"
        ]
      }
    ]
  })
}
