resource "kubernetes_namespace" "dns" {
  metadata {
    name = "dns"
  }
}

module "ing_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "ing"
}

resource "kubernetes_namespace" "elk" {
  metadata {
    name = "elk"
  }
}

resource "kubernetes_namespace" "prod" {
  metadata {
    name = "prod"
  }
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
  }
}

resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dev"
  }
}

resource "kubernetes_namespace" "fargate" {
  metadata {
    name = "fargate"
  }
}

resource "kubernetes_namespace" "ci" {
  metadata {
    name = "ci"
  }
}

resource "kubernetes_namespace" "sys" {
  metadata {
    name = "sys"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

