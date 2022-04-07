locals {
  eks_map_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/administrator"
      username = "administrator"
      groups   = ["system:masters"]
    }
  ]
  eks_map_users = []

  aws_auth_configmap_yaml = <<-CONTENT
    ${chomp(module.eks.aws_auth_configmap_yaml)}
        ${indent(4, yamlencode(local.eks_map_roles))}
      mapUsers: |
        ${indent(4, yamlencode(local.eks_map_users))}
    CONTENT
}

resource "kubectl_manifest" "this" {
  yaml_body = local.aws_auth_configmap_yaml
}
