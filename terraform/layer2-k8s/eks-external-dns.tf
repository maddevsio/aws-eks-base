module "aws_iam_external_dns" {
  source = "../modules/aws-iam-external-dns"

  name              = local.name
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
}

data "template_file" "external_dns" {
  template = file("${path.module}/templates/external-dns.yaml")

  vars = {
    role_arn    = module.aws_iam_external_dns.role_arn
    domain_name = local.domain_name
    zone_type   = "public"
    region      = local.region
  }
}


resource "helm_release" "external_dns" {
  name        = "external-dns"
  chart       = "external-dns"
  repository  = local.helm_repo_bitnami
  version     = var.external_dns_version
  namespace   = kubernetes_namespace.dns.id
  max_history = var.helm_release_history_size

  values = [
    data.template_file.external_dns.rendered,
  ]
}
