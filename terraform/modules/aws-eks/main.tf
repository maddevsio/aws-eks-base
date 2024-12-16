#tfsec:ignore:aws-vpc-no-public-egress-sgr tfsec:ignore:aws-eks-enable-control-plane-logging tfsec:ignore:aws-eks-encrypt-secrets tfsec:ignore:aws-eks-no-public-cluster-access tfsec:ignore:aws-eks-no-public-cluster-access-to-cidr
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.20.0"

  cluster_name             = var.name
  cluster_version          = var.eks_cluster_version
  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.intra_subnets

  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = true
  access_entries                           = var.access_entries

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
      })
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.aws_ebs_csi_driver.iam_role_arn
    }
  }

  cluster_enabled_log_types              = var.eks_cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days = var.eks_cloudwatch_log_group_retention_in_days

  cluster_endpoint_public_access       = var.eks_cluster_endpoint_public_access
  cluster_endpoint_private_access      = var.eks_cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.eks_cluster_endpoint_only_pritunl ? ["0.0.0.0/0"] : ["0.0.0.0/0"]

  node_security_group_tags = { "karpenter.sh/discovery" = var.name }

  node_security_group_additional_rules = {
    ingress_allow_all_traffic_inside = {
      description = "Allow all traffic inside security group"
      protocol    = "all"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  self_managed_node_group_defaults = {
    ami_type = "AL2023_ARM_64_STANDARD"
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          delete_on_termination = true
          encrypted             = true
          volume_size           = 100
          volume_type           = "gp3"
        }

      }
    }
    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 1
      instance_metadata_tags      = "disabled"
    }
    iam_role_attach_cni_policy = false
  }
  self_managed_node_groups = {
    default = {
      name                       = "${var.name}-default"
      iam_role_name              = "${var.name}-default"
      desired_size               = var.node_group_default.desired_capacity
      max_size                   = var.node_group_default.max_capacity
      min_size                   = var.node_group_default.min_capacity
      subnet_ids                 = var.private_subnets
      capacity_rebalance         = var.node_group_default.capacity_rebalance
      use_mixed_instances_policy = var.node_group_default.use_mixed_instances_policy
      mixed_instances_policy     = var.node_group_default.mixed_instances_policy
      cloudinit_pre_nodeadm = [
        {
          content_type = "application/node.eks.aws"
          content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              kubelet:
                config:
                  shutdownGracePeriod: 30s
                  featureGates:
                    DisableKubeletCloudCredentialProviders: true
                  registerWithTaints:
                    - key: CriticalAddonsOnly
                      value: "true"
                      effect: NoSchedule
          EOT
        }
      ]
    }
  }
  fargate_profiles = {
    default = {
      name = "fargate"

      selectors = [
        {
          namespace = "fargate"
        }
      ]

      subnets = var.private_subnets

      tags = merge(var.tags, {
        Namespace = "fargate"
      })
    }
  }

  tags = { "ClusterName" = var.name }
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.39.1"

  role_name             = "${var.name}-vpc-cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = var.tags
}

module "aws_ebs_csi_driver" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.39.1"

  role_name             = "${var.name}-aws-ebs-csi-driver"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}
