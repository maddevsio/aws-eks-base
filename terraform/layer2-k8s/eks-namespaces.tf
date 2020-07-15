resource "kubernetes_namespace" "fargate" {
  metadata {
    name = "fargate"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_namespace" "dns" {
  metadata {
    name = "dns"
  }
}

resource "kubernetes_namespace" "ing" {
  metadata {
    name = "ingresses"
  }
}

resource "kubernetes_namespace" "certmanager" {
  metadata {
    name = "certmanager"
  }
}

resource "kubernetes_namespace" "ci" {
  metadata {
    name = "ci"
  }
}

resource "kubernetes_namespace" "elk" {
  metadata {
    name = "elk"
  }
}

resource "kubernetes_namespace" "wp" {
  metadata {
    name = "wp"
  }
}
