include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

dependency "eks" {
  config_path = "../common/aws-eks"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  mock_outputs = {
    eks_cluster_id                   = "maddevs-khv-demo-euw1"
    eks_oidc_provider_arn            = "arn:aws:iam::746336062380:oidc-provider/oidc.eks.eu-west-1.amazonaws.com/id/E0AD5EAC2B536ED71013DE04B03AB5EF"
    node_group_default_iam_role_arn  = "arn:aws:iam::746336062380:role/maddevs-khv-demo-euw1-default-20250428112004069300000005"
    node_group_default_iam_role_name = "maddevs-khv-demo-euw1-default-20250428112004069300000005"
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
      source  = "gavinbunney/kubectl"
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
  source = "${get_path_to_repo_root()}/terraform/modules//k8s-karpenter"
}

inputs = {
  name                             = include.env.locals.name
  eks_cluster_id                   = dependency.eks.outputs.eks_cluster_id
  eks_oidc_provider_arn            = dependency.eks.outputs.eks_oidc_provider_arn
  node_group_default_iam_role_arn  = dependency.eks.outputs.node_group_default_iam_role_arn
  node_group_default_iam_role_name = dependency.eks.outputs.node_group_default_iam_role_name
  nodepools                        = include.env.locals.values.eks_karpenter_nodepools
}
