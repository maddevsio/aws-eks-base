locals {
  ingress_nginx = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "ingress-nginx")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "ingress-nginx")].name
    chart         = local.helm_releases[index(local.helm_releases.*.id, "ingress-nginx")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "ingress-nginx")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "ingress-nginx")].version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "ingress-nginx")].namespace
  }
  ssl_certificate_arn = var.nginx_ingress_ssl_terminator == "lb" ? data.terraform_remote_state.layer1-aws.outputs.ssl_certificate_arn : ""

  template_name = (
    var.nginx_ingress_ssl_terminator == "lb" ? "nginx-ingress-values.yaml" : (
    var.nginx_ingress_ssl_terminator == "nginx" ? "nginx-ingress-certmanager-ssl-termination-values.yaml" : "")
  )
}

data "template_file" "nginx_ingress" {
  template = file("${path.module}/templates/${local.template_name}")

  vars = {
    hostname           = local.domain_name
    ssl_cert           = local.ssl_certificate_arn
    proxy_real_ip_cidr = local.vpc_cidr
    namespace          = local.ingress_nginx.enabled ? module.ingress_nginx_namespace[0].name : "default"
  }
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
    data.template_file.nginx_ingress.rendered,
  ]

  depends_on = [helm_release.prometheus_operator]
}
