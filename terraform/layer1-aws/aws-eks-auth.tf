data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_id
}

locals {
  eks_map_roles = concat(var.eks_map_roles,
    [{
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/administrator"
      username = "administrator"
      groups = [
        "system:masters"
      ]
    }]
  )

  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = module.eks.cluster_id
      cluster = {
        certificate-authority-data = module.eks.cluster_certificate_authority_data
        server                     = module.eks.cluster_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = module.eks.cluster_id
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.this.token
      }
    }]
  })

  current_auth_configmap = yamldecode(module.eks.aws_auth_configmap_yaml)
  merged_map_roles       = distinct(concat(yamldecode(lookup(local.current_auth_configmap.data, "mapRoles", [])), local.eks_map_roles))
  updated_auth_configmap_data = {
    data = {
      mapRoles = yamlencode(local.merged_map_roles)
    }
  }
}

resource "null_resource" "patch" {
  triggers = {
    kubeconfig = base64encode(local.kubeconfig)

    cmd_patch = "kubectl patch configmap/aws-auth --type merge -p '${chomp(jsonencode(local.updated_auth_configmap_data))}' -n kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode)"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
    command = self.triggers.cmd_patch
  }
}
