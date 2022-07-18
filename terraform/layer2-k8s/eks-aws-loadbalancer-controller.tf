locals {
  aws_load_balancer_controller = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "aws-load-balancer-controller")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "aws-load-balancer-controller")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "aws-load-balancer-controller")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "aws-load-balancer-controller")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "aws-load-balancer-controller")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "aws-load-balancer-controller")].namespace
  }
  aws_load_balancer_controller_webhook_service_name = "${local.aws_load_balancer_controller.name}-webhook-service"

  aws_load_balancer_controller_values = <<VALUES
nameOverride: ${local.aws_load_balancer_controller.name}
clusterName: ${local.eks_cluster_id}
region: ${local.region}
vpcId: ${local.vpc_id}

serviceAccount:
  create: true
  annotations:
     "eks.amazonaws.com/role-arn": ${local.aws_load_balancer_controller.enabled ? module.aws_iam_aws_loadbalancer_controller[0].role_arn : ""}

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
}

module "aws_load_balancer_controller_namespace" {
  count = local.aws_load_balancer_controller.enabled ? 1 : 0

  source = "../modules/eks-kubernetes-namespace"
  name   = local.aws_load_balancer_controller.namespace
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
                name = local.aws_load_balancer_controller.namespace
              }
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
          values   = [local.aws_load_balancer_controller.name]
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

module "aws_iam_aws_loadbalancer_controller" {
  count = local.aws_load_balancer_controller.enabled ? 1 : 0

  source            = "../modules/aws-iam-eks-trusted"
  name              = "${local.name}-aws-lb-controller"
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:CreateServiceLinkedRole"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "iam:AWSServiceName" : "elasticloadbalancing.amazonaws.com"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:GetCoipPoolUsage",
          "ec2:DescribeCoipPools",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateSecurityGroup"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags"
        ],
        "Resource" : "arn:aws:ec2:*:*:security-group/*",
        "Condition" : {
          "StringEquals" : {
            "ec2:CreateAction" : "CreateSecurityGroup"
          },
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ],
        "Resource" : "arn:aws:ec2:*:*:security-group/*",
        "Condition" : {
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "true",
            "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DeleteSecurityGroup"
        ],
        "Resource" : "*",
        "Condition" : {
          "Null" : {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup"
        ],
        "Resource" : "*",
        "Condition" : {
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ],
        "Resource" : [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
        ],
        "Condition" : {
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "true",
            "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ],
        "Resource" : [
          "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DeleteTargetGroup"
        ],
        "Resource" : "*",
        "Condition" : {
          "Null" : {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ],
        "Resource" : "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:SetWebAcl",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:ModifyRule"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "tls_private_key" "aws_loadbalancer_controller_webhook_ca" {
  count = local.aws_load_balancer_controller.enabled ? 1 : 0

  algorithm = "RSA"
}

resource "tls_self_signed_cert" "aws_loadbalancer_controller_webhook_ca" {
  count = local.aws_load_balancer_controller.enabled ? 1 : 0

  private_key_pem       = tls_private_key.aws_loadbalancer_controller_webhook_ca[count.index].private_key_pem
  validity_period_hours = 87600 # 10 years
  early_renewal_hours   = 8760  # 1 year
  is_ca_certificate     = true
  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature"
  ]
  subject {
    common_name  = local.aws_load_balancer_controller_webhook_service_name
    organization = local.name
  }
}

resource "tls_private_key" "aws_loadbalancer_controller_webhook" {
  count = local.aws_load_balancer_controller.enabled ? 1 : 0

  algorithm = "RSA"
}

resource "tls_cert_request" "aws_loadbalancer_controller_webhook" {
  count = local.aws_load_balancer_controller.enabled ? 1 : 0

  private_key_pem = tls_private_key.aws_loadbalancer_controller_webhook[count.index].private_key_pem
  dns_names       = ["${local.aws_load_balancer_controller_webhook_service_name}.${module.aws_load_balancer_controller_namespace[count.index].name}", "${local.aws_load_balancer_controller_webhook_service_name}.${module.aws_load_balancer_controller_namespace[count.index].name}.svc", "${local.aws_load_balancer_controller_webhook_service_name}.${module.aws_load_balancer_controller_namespace[count.index].name}.svc.cluster.local"]
  subject {
    common_name  = local.aws_load_balancer_controller_webhook_service_name
    organization = local.name
  }
}

resource "tls_locally_signed_cert" "aws_loadbalancer_controller_webhook" {
  count = local.aws_load_balancer_controller.enabled ? 1 : 0

  cert_request_pem   = tls_cert_request.aws_loadbalancer_controller_webhook[count.index].cert_request_pem
  ca_private_key_pem = tls_private_key.aws_loadbalancer_controller_webhook_ca[count.index].private_key_pem
  ca_cert_pem        = tls_self_signed_cert.aws_loadbalancer_controller_webhook_ca[count.index].cert_pem

  validity_period_hours = 87600 # 10 years
  early_renewal_hours   = 8760  # 1 year
  allowed_uses = [
    "key_encipherment",
    "digital_signature"
  ]
}

resource "helm_release" "aws_loadbalancer_controller" {
  count = local.aws_load_balancer_controller.enabled ? 1 : 0

  name        = local.aws_load_balancer_controller.name
  chart       = local.aws_load_balancer_controller.chart
  repository  = local.aws_load_balancer_controller.repository
  version     = local.aws_load_balancer_controller.chart_version
  namespace   = module.aws_load_balancer_controller_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    local.aws_load_balancer_controller_values
  ]
  set {
    name  = "webhookTLS.caCert"
    value = tls_self_signed_cert.aws_loadbalancer_controller_webhook_ca[0].cert_pem
  }
  set {
    name  = "webhookTLS.cert"
    value = tls_locally_signed_cert.aws_loadbalancer_controller_webhook[0].cert_pem
  }
  set {
    name  = "webhookTLS.key"
    value = tls_private_key.aws_loadbalancer_controller_webhook[0].private_key_pem
  }
}

resource "kubernetes_ingress_v1" "default" {
  count = local.aws_load_balancer_controller.enabled && local.ingress_nginx.enabled && var.nginx_ingress_ssl_terminator == "lb" ? 1 : 0

  metadata {
    name = "${local.ingress_nginx.name}-controller"
    annotations = {
      "kubernetes.io/ingress.class"                        = "alb"
      "alb.ingress.kubernetes.io/scheme"                   = "internet-facing"
      "alb.ingress.kubernetes.io/tags"                     = "Environment=${local.env},Name=${local.name},Cluster=${local.eks_cluster_id}"
      "alb.ingress.kubernetes.io/certificate-arn"          = "${local.ssl_certificate_arn}"
      "alb.ingress.kubernetes.io/ssl-policy"               = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
      "alb.ingress.kubernetes.io/listen-ports"             = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/target-type"              = "ip"
      "alb.ingress.kubernetes.io/load-balancer-attributes" = "routing.http2.enabled=true"
      "alb.ingress.kubernetes.io/ssl-redirect"             = "443"
    }
    namespace = module.ingress_nginx_namespace[count.index].name
  }
  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = "${local.ingress_nginx.name}-controller"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
  wait_for_load_balancer = true

  depends_on = [helm_release.aws_loadbalancer_controller, helm_release.ingress_nginx, module.aws_iam_aws_loadbalancer_controller, tls_locally_signed_cert.aws_loadbalancer_controller_webhook]
}

resource "aws_route53_record" "default_ingress" {
  count = local.aws_load_balancer_controller.enabled && local.ingress_nginx.enabled && var.nginx_ingress_ssl_terminator == "lb" ? 1 : 0

  zone_id = local.zone_id
  name    = "*.${local.domain_name}"
  type    = "CNAME"
  ttl     = 360

  records = [kubernetes_ingress_v1.default[count.index].status.0.load_balancer.0.ingress.0.hostname]

  depends_on = [
    kubernetes_ingress_v1.default
  ]
}
