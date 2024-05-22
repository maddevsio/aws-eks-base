include "root" {
  path = find_in_parent_folders()
  expose = true
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "../common/aws-vpc"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  mock_outputs = {
    vpc_id = "vpc-0f5b1b5f788888888"
  }
}

dependency "eks" {
  config_path = "../common/aws-eks"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  mock_outputs = {
    eks_cluster_id                   = "test"
    eks_oidc_provider_arn            = "arn:aws:iam::11111111:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/D55EEBDFE5510B81EEE2381B88888888"
    node_group_default_iam_role_arn  = "arn::"
    node_group_default_iam_role_name = "test"
  }
}

dependency "aws-acm" {
  config_path = "../common/aws-acm"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  mock_outputs = {
    ssl_certificate_arn = "arn:aws:acm:us-east-1:111111111:certificate/fa029132-86ab-7777-8888-1111111"
  }
}

dependency "aws-r53" {
  config_path = "../common/aws-r53"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  mock_outputs = {
    route53_zone_id = "Z058363314IT7VAKRA777"
  }
}

generate "providers_versions" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = ">= 1.8.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "${include.root.locals.tf_providers.aws}"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "${include.root.locals.tf_providers.kubernetes}"
    }
    kubectl = {
      source  = "avinbunney/kubectl"
      version = "${include.root.locals.tf_providers.kubectl}"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "${include.root.locals.tf_providers.helm}"
    }
    http = {
      source  = "hashicorp/http"
      version = "${include.root.locals.tf_providers.http}"
    }
  }
}
EOF
}

terraform {
  source = "${get_path_to_repo_root()}/terraform/modules//k8s-addons"
}

inputs = {
  name                             = include.env.locals.name
  name_wo_region                   = include.env.locals.name_wo_region
  environment                      = include.env.locals.values.environment
  vpc_cidr                         = include.env.locals.values.vpc_cidr
  vpc_id                           = dependency.vpc.outputs.vpc_id
  eks_cluster_id                   = dependency.eks.outputs.eks_cluster_id
  eks_oidc_provider_arn            = dependency.eks.outputs.eks_oidc_provider_arn
  node_group_default_iam_role_arn  = dependency.eks.outputs.node_group_default_iam_role_arn
  node_group_default_iam_role_name = dependency.eks.outputs.node_group_default_iam_role_name
  zone_id                          = dependency.aws-r53.outputs.route53_zone_id
  ssl_certificate_arn              = dependency.aws-acm.outputs.ssl_certificate_arn
  helm_charts_path                 = "${get_path_to_repo_root()}/helm-charts"
}
