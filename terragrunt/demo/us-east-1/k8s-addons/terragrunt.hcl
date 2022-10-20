include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "${get_terragrunt_dir()}/../../../../terraform//layer2-k8s"
}

dependencies {
  paths = ["../aws-base"]
}

dependency "aws-base" {
  config_path = "../aws-base"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  mock_outputs = {
    route53_zone_id       = "Z058363314IT7VAKRA777"
    vpc_id                = "vpc-0f5b1b5f788888888"
    vpc_cidr              = "10.0.0.0/16"
    eks_cluster_id        = "maddevs-demo-use1"
    eks_oidc_provider_arn = "arn:aws:iam::730808884724:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/D55EEBDFE5510B81EEE2381B88888888"
    ssl_certificate_arn   = "arn:aws:acm:us-east-1:730808884724:certificate/fa029132-86ab-7777-8888-8e1fd5c56c29"
  }
}

inputs = {
  zone_id               = dependency.aws-base.outputs.route53_zone_id
  vpc_id                = dependency.aws-base.outputs.vpc_id
  vpc_cidr              = dependency.aws-base.outputs.vpc_cidr
  eks_cluster_id        = dependency.aws-base.outputs.eks_cluster_id
  eks_oidc_provider_arn = dependency.aws-base.outputs.eks_oidc_provider_arn
  ssl_certificate_arn   = dependency.aws-base.outputs.ssl_certificate_arn
}
