include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "${get_terragrunt_dir()}/../../../../terraform//layer2-k8s"
}

dependencies {
  paths = ["../aws-base", "../vpc", "../eks"]
}

dependency "aws-base" {
  config_path = "../aws-base"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  mock_outputs = {
    route53_zone_id                  = "Z058363314IT7VAKRA777"
    ssl_certificate_arn              = "arn:aws:acm:us-east-1:730808884724:certificate/fa029132-86ab-7777-8888-8e1fd5c56c29"
  }
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  mock_outputs = {
    vpc_id                           = "vpc-0f5b1b5f788888888"
    vpc_cidr                         = "10.0.0.0/16"
    vpc_private_subnets = ["10.0.0.0/16"]
    vpc_public_subnets = ["10.0.0.0/16"]
    vpc_intra_subnets = ["10.0.0.0/16"]
  }
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  mock_outputs = {
    eks_cluster_id                   = "test"
    eks_oidc_provider_arn            = "arn:aws:iam::11111111:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/D55EEBDFE5510B81EEE2381B88888888"
    node_group_default_iam_role_arn = "arn::"
    node_group_default_iam_role_name = "test"
    eks_auth_token = "test"
    cluster_ca_certificate = "test"
    eks_cluster_endpoint = "test"
  }
}

generate "provider_kubernetes" {
  path      = "provider_kubernetes.tf"
  if_exists = "overwrite"
  contents  = file(find_in_parent_folders("provider_kubernetes.hcl"))
}

inputs = {
  zone_id                          = dependency.aws-base.outputs.route53_zone_id
  ssl_certificate_arn              = dependency.aws-base.outputs.ssl_certificate_arn
  vpc_id                           = dependency.vpc.outputs.vpc_id
  vpc_cidr                         = dependency.vpc.outputs.vpc_cidr
  eks_cluster_id                   = dependency.eks.outputs.eks_cluster_id
  eks_oidc_provider_arn            = dependency.eks.outputs.eks_oidc_provider_arn
  node_group_default_iam_role_arn  = dependency.eks.outputs.node_group_default_iam_role_arn
  node_group_default_iam_role_name = dependency.eks.outputs.node_group_default_iam_role_name
  eks_auth_token = dependency.eks.outputs.eks_auth_token
  cluster_ca_certificate = dependency.eks.outputs.cluster_ca_certificate
  eks_cluster_endpoint = dependency.eks.outputs.eks_cluster_endpoint
  helm_charts_path                 = "${get_terragrunt_dir()}/../../../../helm-charts"
}
