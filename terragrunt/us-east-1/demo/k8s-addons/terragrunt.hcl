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
  paths = ["../common/aws-base", "../common/vpc", "../common/eks"]
}

dependency "aws-base" {
  config_path = "../common/aws-base"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  mock_outputs = {
    route53_zone_id     = "Z058363314IT7VAKRA777"
    ssl_certificate_arn = "arn:aws:acm:us-east-1:730808884724:certificate/fa029132-86ab-7777-8888-8e1fd5c56c29"
  }
}

dependency "vpc" {
  config_path = "../common/vpc"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  mock_outputs = {
    vpc_id              = "vpc-0f5b1b5f788888888"
    vpc_cidr            = "10.0.0.0/16"
    vpc_private_subnets = ["10.0.0.0/16"]
    vpc_public_subnets  = ["10.0.0.0/16"]
    vpc_intra_subnets   = ["10.0.0.0/16"]
  }
}

dependency "eks" {
  config_path = "../common/eks"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  mock_outputs = {
    eks_cluster_id                   = "test"
    eks_oidc_provider_arn            = "arn:aws:iam::11111111:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/D55EEBDFE5510B81EEE2381B88888888"
    node_group_default_iam_role_arn  = "arn::"
    node_group_default_iam_role_name = "test"
  }
}

generate "providers" {
  path      = "providers-override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "kubernetes" {
      host                   = data.aws_eks_cluster.main.endpoint
      cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority.0.data)
      token                  = data.aws_eks_cluster_auth.main.token
    }

    provider "kubectl" {
      host                   = data.aws_eks_cluster.main.endpoint
      cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority.0.data)
      token                  = data.aws_eks_cluster_auth.main.token
    }

    provider "helm" {
      kubernetes {
        host                   = data.aws_eks_cluster.main.endpoint
        cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority.0.data)
        token                  = data.aws_eks_cluster_auth.main.token
      }

      experiments {
        manifest = true
      }
    }

    data "aws_eks_cluster" "main" {
      name = var.eks_cluster_id
    }

    data "aws_eks_cluster_auth" "main" {
      name = var.eks_cluster_id
    }
  EOF
}

inputs = {
  name                             = include.env.locals.name
  name_wo_region                   = include.env.locals.name_wo_region
  environment                      = include.env.locals.values.environment
  zone_id                          = dependency.aws-base.outputs.route53_zone_id
  ssl_certificate_arn              = dependency.aws-base.outputs.ssl_certificate_arn
  vpc_id                           = dependency.vpc.outputs.vpc_id
  vpc_cidr                         = dependency.vpc.outputs.vpc_cidr
  eks_cluster_id                   = dependency.eks.outputs.eks_cluster_id
  eks_oidc_provider_arn            = dependency.eks.outputs.eks_oidc_provider_arn
  node_group_default_iam_role_arn  = dependency.eks.outputs.node_group_default_iam_role_arn
  node_group_default_iam_role_name = dependency.eks.outputs.node_group_default_iam_role_name
  helm_charts_path                 = "${get_terragrunt_dir()}/../../../../helm-charts"
}
