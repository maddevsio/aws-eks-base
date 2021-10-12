locals {
  eks_map_roles = concat(var.eks_map_roles,
    [
      {
        rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/administrator"
        username = "administrator"
        groups = [
        "system:masters"]
    }]
  )

  worker_tags = [
    {
      "key"                 = "k8s.io/cluster-autoscaler/enabled"
      "propagate_at_launch" = "false"
      "value"               = "true"
    },
    {
      "key"                 = "k8s.io/cluster-autoscaler/${local.name}"
      "propagate_at_launch" = "false"
      "value"               = "owned"
    }
  ]
}

#tfsec:ignore:aws-vpc-no-public-egress-sgr tfsec:ignore:aws-eks-enable-control-plane-logging tfsec:ignore:aws-eks-encrypt-secrets tfsec:ignore:aws-eks-no-public-cluster-access tfsec:ignore:aws-eks-no-public-cluster-access-to-cidr
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.3.0"

  cluster_name    = local.name
  cluster_version = var.eks_cluster_version
  subnets         = module.vpc.intra_subnets
  enable_irsa     = true

  cluster_enabled_log_types     = var.eks_cluster_enabled_log_types
  cluster_log_retention_in_days = var.eks_cluster_log_retention_in_days

  tags = {
    ClusterName = local.name
    Environment = local.env
  }

  vpc_id = module.vpc.vpc_id

  cluster_encryption_config = var.eks_cluster_encryption_config_enable ? [
    {
      provider_key_arn = aws_kms_key.eks[0].arn
      resources        = ["secrets"]
    }
  ] : []

  map_roles        = local.eks_map_roles
  write_kubeconfig = var.eks_write_kubeconfig

  # Create security group rules to allow communication between pods on workers and pods in managed node groups.
  # Set this to true if you have AWS-Managed node groups and Self-Managed worker groups.
  # See https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1089
  worker_create_cluster_primary_security_group_rules = true

  workers_additional_policies = var.eks_workers_additional_policies

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 100
  }

  node_groups = {
    spot = {
      desired_capacity = var.node_group_spot.desired_capacity
      max_capacity     = var.node_group_spot.max_capacity
      min_capacity     = var.node_group_spot.min_capacity
      instance_types   = var.node_group_spot.instance_types
      capacity_type    = var.node_group_spot.capacity_type
      subnets          = module.vpc.private_subnets

      force_update_version = var.node_group_spot.force_update_version

      k8s_labels = {
        Environment = local.env
        nodegroup   = "spot"
      }
      additional_tags = {
        Name = "${local.name}-spot"
      }
    },
    ondemand = {
      desired_capacity = var.node_group_ondemand.desired_capacity
      max_capacity     = var.node_group_ondemand.max_capacity
      min_capacity     = var.node_group_ondemand.min_capacity
      instance_types   = var.node_group_ondemand.instance_types
      capacity_type    = var.node_group_ondemand.capacity_type
      subnets          = module.vpc.private_subnets

      force_update_version = var.node_group_ondemand.force_update_version

      k8s_labels = {
        Environment = local.env
        nodegroup   = "ondemand"
      }
      additional_tags = {
        Name = "${local.name}-ondemand"
      }
    },
    ci = {
      desired_capacity = var.node_group_ci.desired_capacity
      max_capacity     = var.node_group_ci.max_capacity
      min_capacity     = var.node_group_ci.min_capacity
      instance_types   = var.node_group_ci.instance_types
      capacity_type    = var.node_group_ci.capacity_type
      subnets          = module.vpc.private_subnets

      force_update_version = var.node_group_ci.force_update_version

      k8s_labels = {
        Environment = local.env
        nodegroup   = "ci"
      }
      additional_tags = {
        Name = "${local.name}-ci"
      }
      taints = [
        {
          key    = "nodegroup"
          value  = "ci"
          effect = "NO_SCHEDULE"
      }]
    }
  }

  worker_groups_launch_template = [
    {
      name                    = "bottlerocket-spot"
      ami_id                  = data.aws_ami.bottlerocket_ami.id
      override_instance_types = var.worker_group_bottlerocket.instance_types
      spot_instance_pools     = var.worker_group_bottlerocket.spot_instance_pools
      asg_max_size            = var.worker_group_bottlerocket.max_capacity
      asg_min_size            = var.worker_group_bottlerocket.min_capacity
      asg_desired_capacity    = var.worker_group_bottlerocket.desired_capacity
      subnets                 = module.vpc.private_subnets
      public_ip               = false
      userdata_template_file  = "${path.module}/templates/userdata-bottlerocket.tpl"
      userdata_template_extra_args = {
        enable_admin_container   = false
        enable_control_container = true
      }
      additional_userdata = <<EOT
[settings.kubernetes.node-labels]
"eks.amazonaws.com/capacityType" = "SPOT"
"nodegroup" = "bottlerocket"

[settings.kubernetes.node-taints]
"nodegroup" = "bottlerocket:NoSchedule"
EOT

      tags = concat(local.worker_tags, [{
        "key"                 = "k8s.io/cluster-autoscaler/node-template/label/nodegroup"
        "propagate_at_launch" = "true"
        "value"               = "bottlerocket"
      }])
    }
  ]

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

  depends_on = [module.vpc]
}

resource "aws_eks_addon" "vpc_cni" {
  count = var.addon_create_vpc_cni ? 1 : 0

  cluster_name      = module.eks.cluster_id
  addon_name        = "vpc-cni"
  resolve_conflicts = "OVERWRITE"
  addon_version     = var.addon_vpc_cni_version

  tags = {
    Environment = local.env
  }

  depends_on = [module.eks]
}

resource "aws_eks_addon" "kube_proxy" {
  count = var.addon_create_kube_proxy ? 1 : 0

  cluster_name      = module.eks.cluster_id
  addon_name        = "kube-proxy"
  resolve_conflicts = "OVERWRITE"
  addon_version     = var.addon_kube_proxy_version

  tags = {
    Environment = local.env
  }

  depends_on = [module.eks]
}

resource "aws_eks_addon" "coredns" {
  count = var.addon_create_coredns ? 1 : 0

  cluster_name      = module.eks.cluster_id
  addon_name        = "coredns"
  resolve_conflicts = "OVERWRITE"
  addon_version     = var.addon_coredns_version

  tags = {
    Environment = local.env
  }

  depends_on = [module.eks]
}
