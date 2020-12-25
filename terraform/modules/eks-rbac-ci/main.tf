resource "kubernetes_service_account" "main" {
  metadata {
    name      = var.name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = var.role_arn
    }
  }
  automount_service_account_token = true
}

resource "kubernetes_role" "staging" {
  metadata {
    name      = "${var.name}-staging"
    namespace = "staging"
  }

  rule {
    api_groups = ["", "apps", "extensions", "batch", "networking.k8s.io", "kubernetes-client.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role" "prod" {
  metadata {
    name      = "${var.name}-prod"
    namespace = "prod"
  }

  rule {
    api_groups = ["", "apps", "extensions", "batch", "networking.k8s.io", "kubernetes-client.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role" "dev" {
  metadata {
    name      = "${var.name}-dev"
    namespace = "dev"
  }

  rule {
    api_groups = ["", "apps", "extensions", "batch", "networking.k8s.io", "kubernetes-client.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role" "ci" {
  metadata {
    name      = "${var.name}-ci"
    namespace = "ci"
  }

  rule {
    api_groups = ["", "apps", "extensions", "batch", "networking.k8s.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "staging" {
  metadata {
    name      = "${var.name}-staging"
    namespace = "staging"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.staging.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.main.metadata.0.name
    namespace = var.namespace
  }
}

resource "kubernetes_role_binding" "prod" {
  metadata {
    name      = "${var.name}-prod"
    namespace = "prod"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.prod.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.main.metadata.0.name
    namespace = var.namespace
  }
}

resource "kubernetes_role_binding" "dev" {
  metadata {
    name      = "${var.name}-dev"
    namespace = "dev"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.dev.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.main.metadata.0.name
    namespace = var.namespace
  }
}

resource "kubernetes_role_binding" "ci" {
  metadata {
    name      = "${var.name}-ci"
    namespace = "ci"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.ci.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.main.metadata.0.name
    namespace = var.namespace
  }
}
