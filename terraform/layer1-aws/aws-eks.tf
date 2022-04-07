#tfsec:ignore:aws-vpc-no-public-egress-sgr tfsec:ignore:aws-eks-enable-control-plane-logging tfsec:ignore:aws-eks-encrypt-secrets tfsec:ignore:aws-eks-no-public-cluster-access tfsec:ignore:aws-eks-no-public-cluster-access-to-cidr
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.9.0"

  cluster_name    = local.name
  cluster_version = var.eks_cluster_version
  subnet_ids      = module.vpc.intra_subnets
  enable_irsa     = true

  cluster_enabled_log_types              = var.eks_cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days = var.eks_cloudwatch_log_group_retention_in_days

  tags = {
    ClusterName = local.name
    Environment = local.env
  }

  vpc_id = module.vpc.vpc_id

  cluster_addons = var.eks_addons

  cluster_encryption_config = var.eks_cluster_encryption_config_enable ? [
    {
      provider_key_arn = aws_kms_key.eks[0].arn
      resources        = ["secrets"]
    }
  ] : []

  cluster_endpoint_public_access       = var.eks_cluster_endpoint_public_access
  cluster_endpoint_private_access      = var.eks_cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.eks_cluster_endpoint_only_pritunl ? ["${module.pritunl[0].pritunl_endpoint}/32"] : ["0.0.0.0/0"]

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_cluster_all = {
      description                   = "Cluster to nodes all ports/protocols"
      protocol                      = "-1"
      from_port                     = 1025
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_group_defaults = {
    ami_type                     = "AL2_x86_64"
    disk_size                    = 100
    iam_role_additional_policies = var.eks_workers_additional_policies
  }

  eks_managed_node_groups = {
    spot = {
      name           = "${local.name}-spot"
      iam_role_name  = "${local.name}-spot"
      desired_size   = var.node_group_spot.desired_capacity
      max_size       = var.node_group_spot.max_capacity
      min_size       = var.node_group_spot.min_capacity
      instance_types = var.node_group_spot.instance_types
      capacity_type  = var.node_group_spot.capacity_type
      subnet_ids     = module.vpc.private_subnets

      force_update_version = var.node_group_spot.force_update_version

      labels = {
        Environment = local.env
        nodegroup   = "spot"
      }
      tags = {
        Name = "${local.name}-spot"
      }
    },
    ondemand = {
      name           = "${local.name}-ondemand"
      iam_role_name  = "${local.name}-ondemand"
      desired_size   = var.node_group_ondemand.desired_capacity
      max_size       = var.node_group_ondemand.max_capacity
      min_size       = var.node_group_ondemand.min_capacity
      instance_types = var.node_group_ondemand.instance_types
      capacity_type  = var.node_group_ondemand.capacity_type
      subnet_ids     = module.vpc.private_subnets

      force_update_version = var.node_group_ondemand.force_update_version

      labels = {
        Environment = local.env
        nodegroup   = "ondemand"
      }
      tags = {
        Name = "${local.name}-ondemand"
      }
    },
    ci = {
      name           = "${local.name}-ci"
      iam_role_name  = "${local.name}-ci"
      desired_size   = var.node_group_ci.desired_capacity
      max_size       = var.node_group_ci.max_capacity
      min_size       = var.node_group_ci.min_capacity
      instance_types = var.node_group_ci.instance_types
      capacity_type  = var.node_group_ci.capacity_type
      subnet_ids     = module.vpc.private_subnets

      force_update_version = var.node_group_ci.force_update_version

      labels = {
        Environment = local.env
        nodegroup   = "ci"
      }
      tags = {
        Name = "${local.name}-ci"
      }
      taints = [
        {
          key    = "nodegroup"
          value  = "ci"
          effect = "NO_SCHEDULE"
        }
      ]
    },
    bottlerocket = {
      name           = "${local.name}-bottlerocket"
      iam_role_name  = "${local.name}-bottlerocket"
      desired_size   = var.node_group_br.desired_capacity
      max_size       = var.node_group_br.max_capacity
      min_size       = var.node_group_br.min_capacity
      instance_types = var.node_group_br.instance_types
      capacity_type  = var.node_group_br.capacity_type
      subnet_ids     = module.vpc.private_subnets

      ami_type = "BOTTLEROCKET_x86_64"

      force_update_version = var.node_group_br.force_update_version

      labels = {
        Environment = local.env
        nodegroup   = "bottlerocket"
      }
      taints = [
        {
          key    = "nodegroup"
          value  = "bottlerocket"
          effect = "NO_SCHEDULE"
        }
      ]
      tags = {
        Name = "${local.name}-bottlerocket"
      }
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

      subnets = module.vpc.private_subnets

      tags = merge(local.tags, {
        Namespace = "fargate"
      })
    }
  }
}
