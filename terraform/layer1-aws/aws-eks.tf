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

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.1.0"

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

  workers_additional_policies = [
  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]

  cluster_encryption_config = var.eks_cluster_encryption_config_enable ? [
    {
      provider_key_arn = aws_kms_key.eks[0].arn
      resources        = ["secrets"]
    }
  ] : []

  # Create security group rules to allow communication between pods on workers and pods in managed node groups.
  # Set this to true if you have AWS-Managed node groups and Self-Managed worker groups.
  # See https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1089
  worker_create_cluster_primary_security_group_rules = true

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 100
  }

  node_groups = {
    spot = {
      desired_capacity = var.node_pool_spot.desired_capacity
      max_capacity     = var.node_pool_spot.max_capacity
      min_capacity     = var.node_pool_spot.min_capacity
      instance_types   = var.node_pool_spot.instance_types
      capacity_type    = var.node_pool_spot.capacity_type
      subnets          = module.vpc.private_subnets

      k8s_labels = {
        Environment = local.env
        nodegroup   = "spot"
      }
      additional_tags = {
        Name = "${local.name}-spot"
      }
    },
    ondemand = {
      desired_capacity = var.node_pool_ondemand.desired_capacity
      max_capacity     = var.node_pool_ondemand.max_capacity
      min_capacity     = var.node_pool_ondemand.min_capacity
      instance_types   = var.node_pool_ondemand.instance_types
      capacity_type    = var.node_pool_ondemand.capacity_type
      subnets          = module.vpc.private_subnets

      k8s_labels = {
        Environment = local.env
        nodegroup   = "ondemand"
      }
      additional_tags = {
        Name = "${local.name}-ondemand"
      }
    },
    ci = {
      desired_capacity = var.node_pool_ci.desired_capacity
      max_capacity     = var.node_pool_ci.max_capacity
      min_capacity     = var.node_pool_ci.min_capacity
      instance_types   = var.node_pool_ci.instance_types
      capacity_type    = var.node_pool_ci.capacity_type
      subnets          = module.vpc.private_subnets

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
      override_instance_types = var.eks_worker_groups.bottlerocket_spot.override_instance_types
      spot_instance_pools     = var.eks_worker_groups.bottlerocket_spot.spot_instance_pools
      asg_max_size            = var.eks_worker_groups.bottlerocket_spot.asg_max_size
      asg_min_size            = var.eks_worker_groups.bottlerocket_spot.asg_min_size
      asg_desired_capacity    = var.eks_worker_groups.bottlerocket_spot.asg_desired_capacity
      subnets                 = module.vpc.private_subnets
      public_ip               = false
      userdata_template_file  = "${path.module}/templates/userdata-bottlerocket.tpl"
      userdata_template_extra_args = {
        enable_admin_container   = false
        enable_control_container = true
      }
      additional_userdata = <<EOT
[settings.kubernetes.node-labels]
"node.kubernetes.io/lifecycle" = "spot"
"nodegoup" = "bottlerocket"

[settings.kubernetes.node-taints]
"nodegroup" = "bottlerocket:NoSchedule"
EOT

      tags = concat(local.worker_tags, [{
        "key"                 = "k8s.io/cluster-autoscaler/node-template/label/purpose"
        "propagate_at_launch" = "true"
        "value"               = "experimental"
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

  map_roles        = local.eks_map_roles
  write_kubeconfig = var.eks_write_kubeconfig
}
