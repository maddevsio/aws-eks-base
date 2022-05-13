locals {
  ingress_nginx = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "ingress-nginx")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "ingress-nginx")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "ingress-nginx")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "ingress-nginx")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "ingress-nginx")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "ingress-nginx")].namespace
  }
  ssl_certificate_arn                         = var.nginx_ingress_ssl_terminator == "lb" ? data.terraform_remote_state.layer1-aws.outputs.ssl_certificate_arn : "ssl-certificate"
  ingress_nginx_general_values                = <<VALUES
rbac:
  create: true
controller:
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true

  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: eks.amazonaws.com/capacityType
            operator: In
            values:
              - ON_DEMAND
VALUES
  ingress_loadbalancer_ssl_termination_values = <<VALUES
controller:
  service:
    targetPorts:
      http: http
      https: http
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
      service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: '60'
      service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "https"
      service.beta.kubernetes.io/aws-load-balancer-ssl-cert: ${local.ssl_certificate_arn}
      service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy: ELBSecurityPolicy-TLS-1-2-2017-01
      external-dns.alpha.kubernetes.io/hostname: ${local.domain_name}.
  publishService:
    enabled: true
  config:
    server-tokens: "false"
    use-forwarded-headers: "true"
    set-real-ip-from: "${local.vpc_cidr}"
VALUES
  ingress_pod_ssl_termination_values          = <<VALUES
controller:
  extraArgs:
    default-ssl-certificate: "${local.ingress_nginx.enabled ? module.ingress_nginx_namespace[0].name : "default"}/nginx-tls"
  containerPort:
    http: 80
    https: 443
  service:
    targetPorts:
      http: http
      https: https
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
      service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: "*"
      service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: '60'
      service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "https"
      # service.beta.kubernetes.io/aws-load-balancer-type: nlb
      external-dns.alpha.kubernetes.io/hostname: ${local.domain_name}.
  publishService:
    enabled: true
  config:
    server-tokens: "false"
    use-forwarded-headers: "true"
    use-proxy-protocol: "true"
    set-real-ip-from: "${local.vpc_cidr}"
    real-ip-header: "proxy_protocol"
VALUES
}

#tfsec:ignore:kubernetes-network-no-public-egress tfsec:ignore:kubernetes-network-no-public-ingress
module "ingress_nginx_namespace" {
  count = local.ingress_nginx.enabled ? 1 : 0

  source = "../modules/kubernetes-namespace"
  name   = local.ingress_nginx.namespace
  network_policies = [
    {
      name         = "default-deny"
      policy_types = ["Ingress", "Egress"]
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
                name = local.ingress_nginx.namespace
              }
            }
          }
        ]
      }
    },
    {
      name         = "allow-ingress"
      policy_types = ["Ingress"]
      pod_selector = {
        match_expressions = {
          key      = "app.kubernetes.io/name"
          operator = "In"
          values   = [local.ingress_nginx.name]
        }
      }
      ingress = {
        ports = [
          {
            port     = "80"
            protocol = "TCP"
          },
          {
            port     = "443"
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
      name         = "allow-control-plane"
      policy_types = ["Ingress"]
      pod_selector = {
        match_expressions = {
          key      = "app.kubernetes.io/name"
          operator = "In"
          values   = [local.ingress_nginx.name]
        }
      }
      ingress = {
        ports = [
          {
            port     = "8443"
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
      name         = "allow-monitoring"
      policy_types = ["Ingress"]
      pod_selector = {
        match_expressions = {
          key      = "app.kubernetes.io/name"
          operator = "In"
          values   = [local.ingress_nginx.name]
        }
      }
      ingress = {
        ports = [
          {
            port     = "metrics"
            protocol = "TCP"
          }
        ]
        from = [
          {
            namespace_selector = {
              match_labels = {
                name = "monitoring"
              }
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

resource "helm_release" "ingress_nginx" {
  count = local.ingress_nginx.enabled ? 1 : 0

  name        = local.ingress_nginx.name
  chart       = local.ingress_nginx.chart
  repository  = local.ingress_nginx.repository
  version     = local.ingress_nginx.chart_version
  namespace   = module.ingress_nginx_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    local.ingress_nginx_general_values,
    var.nginx_ingress_ssl_terminator == "lb" ? local.ingress_loadbalancer_ssl_termination_values : local.ingress_pod_ssl_termination_values
  ]

  depends_on = [kubectl_manifest.kube_prometheus_stack_operator_crds]
}
