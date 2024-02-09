
provider "kubernetes" {
  host                   = var.eks_cluster_endpoint
  cluster_ca_certificate = var.cluster_ca_certificate
  token                  = var.eks_auth_token
}

provider "kubectl" {
  host                   = var.eks_cluster_endpoint
  cluster_ca_certificate = var.cluster_ca_certificate
  token                  = var.eks_auth_token
}

provider "helm" {
  kubernetes {
    host                   = var.eks_cluster_endpoint
    cluster_ca_certificate = var.cluster_ca_certificate
    token                  = var.eks_auth_token
  }

  experiments {
    manifest = true
  }
}

