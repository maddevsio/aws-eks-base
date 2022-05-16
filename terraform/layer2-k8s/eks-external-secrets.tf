locals {
  external_secrets = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "external-secrets")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "external-secrets")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "external-secrets")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "external-secrets")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "external-secrets")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "external-secrets")].namespace
  }
  external_secrets_values = <<VALUES
crds:
  createClusterExternalSecret: false
  createClusterSecretStore: true # without setting it to true, certcontroller couldn't start: {"level":"debug","ts":1651041439.6815717,"logger":"controller-runtime.healthz","msg":"healthz check failed","checker":"crd-inject","error":"resource not ready: clustersecretstores.external-secrets.io"}

processClusterExternalSecret: false
processClusterStore: false

securityContext:
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 200m
    memory: 128Mi

webhook:
  securityContext:
    capabilities:
      drop:
      - ALL
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    runAsUser: 1000

  resources:
    requests:
      cpu: 50m
      memory: 64Mi
    limits:
      cpu: 100m
      memory: 64Mi

certController:
  securityContext:
    capabilities:
      drop:
      - ALL
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    runAsUser: 1000

  resources:
    requests:
      cpu: 50m
      memory: 64Mi
    limits:
      cpu: 100m
      memory: 64Mi
VALUES
}

module "external_secrets_namespace" {
  count = local.external_secrets.enabled ? 1 : 0

  source = "../modules/eks-kubernetes-namespace"
  name   = local.external_secrets.namespace
  network_policies = [
    {
      name         = "default-deny"
      policy_types = ["Ingress"]
      pod_selector = {}
    },
    {
      name         = "allow-this-namespace"
      policy_types = ["Ingress"]
      pod_selector = {}
      ingress = {
        from = [
          {
            namespace_selector = {
              match_labels = {
                name = local.external_secrets.namespace
              }
            }
          }
        ]
      }
    },
    {
      name         = "allow-webhooks"
      policy_types = ["Ingress"]
      pod_selector = {
        match_expressions = {
          key      = "app.kubernetes.io/name"
          operator = "In"
          values   = ["${local.external_secrets.name}-webhook"]
        }
      }
      ingress = {
        ports = [
          {
            port     = "9443"
            protocol = "TCP"
          }
        ]
        from = [
          {
            ip_block = {
              cidr = "0.0.0.0/0"
            }
          }
        ]
      }
    },
    {
      name         = "allow-egress"
      policy_types = ["Egress"]
      pod_selector = {}
      egress = {
        to = [
          {
            ip_block = {
              cidr = "0.0.0.0/0"
              except = [
                "169.254.169.254/32"
              ]
            }
          }
        ]
      }
    }
  ]
}

resource "helm_release" "external_secrets" {
  count = local.external_secrets.enabled ? 1 : 0

  name        = local.external_secrets.name
  chart       = local.external_secrets.chart
  repository  = local.external_secrets.repository
  version     = local.external_secrets.chart_version
  namespace   = module.external_secrets_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    local.external_secrets_values
  ]

}
