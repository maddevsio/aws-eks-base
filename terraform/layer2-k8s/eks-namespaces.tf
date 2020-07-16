resource "kubernetes_namespace" "dns" {
  metadata {
    name = "dns"
  }
}

resource "kubernetes_namespace" "ing" {
  metadata {
    name = "ing"
  }
}

resource "kubernetes_namespace" "elk" {
  metadata {
    name = "elk"
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
