module "aws_iam_cert_manager" {
  source = "../modules/aws-iam-external-dns"

  name              = local.name
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
}

data "template_file" "cert_manager" {
  template = file("${path.module}/templates/cert-manager-values.yaml")

  vars = {
    role_arn = module.aws_iam_cert_manager.role_arn
  }
}

resource "helm_release" "cert_manager" {
  name        = "cert-manager"
  chart       = "cert-manager"
  repository  = local.helm_repo_certmanager
  namespace   = kubernetes_namespace.certmanager.id
  version     = var.cert_manager_version
  wait        = true
  max_history = var.helm_release_history_size

  values = [
    data.template_file.cert_manager.rendered,
  ]
}

resource "kubernetes_namespace" "certmanager" {
  metadata {
    name = "certmanager"
  }
}
