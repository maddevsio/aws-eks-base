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
      "value"               = "true"
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

  cluster_encryption_config = var.eks_cluster_encryption_config_enable ? [
    {
      provider_key_arn = aws_kms_key.eks[0].arn
      resources        = ["secrets"]
    }
  ] : []

  worker_groups_launch_template = [
    {
      name                    = "spot"
      override_instance_types = var.eks_worker_groups.spot.override_instance_types
      spot_instance_pools     = var.eks_worker_groups.spot.spot_instance_pools
      asg_max_size            = var.eks_worker_groups.spot.asg_max_size
      asg_min_size            = var.eks_worker_groups.spot.asg_min_size
      asg_desired_capacity    = var.eks_worker_groups.spot.asg_desired_capacity
      subnets                 = module.vpc.private_subnets
      kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
      public_ip               = false
      additional_userdata     = file("${path.module}/templates/eks-x86-nodes-userdata.sh")

      tags = local.worker_tags
    },
    {
      name                 = "ondemand"
      instance_type        = var.eks_worker_groups.ondemand.instance_type
      asg_desired_capacity = var.eks_worker_groups.ondemand.asg_desired_capacity
      subnets              = module.vpc.private_subnets
      asg_max_size         = var.eks_worker_groups.ondemand.asg_max_size
      cpu_credits          = "unlimited"
      kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=ondemand"
      public_ip            = false
      additional_userdata  = file("${path.module}/templates/eks-x86-nodes-userdata.sh")

      tags = local.worker_tags
    },
    {
      name                    = "ci"
      override_instance_types = var.eks_worker_groups.ci.override_instance_types
      spot_instance_pools     = var.eks_worker_groups.ci.spot_instance_pools
      asg_max_size            = var.eks_worker_groups.ci.asg_max_size
      asg_min_size            = var.eks_worker_groups.ci.asg_min_size
      asg_desired_capacity    = var.eks_worker_groups.ci.asg_desired_capacity
      subnets                 = module.vpc.public_subnets
      cpu_credits             = "unlimited"
      kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot --node-labels=purpose=ci --register-with-taints=purpose=ci:NoSchedule"
      public_ip               = true
      additional_userdata     = file("${path.module}/templates/eks-x86-nodes-userdata.sh")

      tags = concat(local.worker_tags, [{
        "key"                 = "k8s.io/cluster-autoscaler/node-template/label/purpose"
        "propagate_at_launch" = "true"
        "value"               = "ci"
      }])
    },
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
