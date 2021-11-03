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
  namespace   = module.dns_namespace.name
  max_history = var.helm_release_history_size

  values = [
    data.template_file.external_dns.rendered,
  ]
}

#tfsec:ignore:aws-iam-no-policy-wildcards
module "aws_iam_external_dns" {
  source = "../modules/aws-iam-eks-trusted"

  name              = "${local.name}-external-dns"
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "route53:GetChange",
        "Resource" : "arn:aws:route53:::change/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZones"
        ],
        "Resource" : ["*"]
      },
      {
        "Effect" : "Allow",
        "Action" : "route53:ListHostedZonesByName",
        "Resource" : "*"
      }
    ]
  })
}
