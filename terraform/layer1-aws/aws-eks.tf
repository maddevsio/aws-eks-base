module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "12.2.0"

  cluster_name    = local.name
  cluster_version = var.eks_cluster_version
  subnets         = module.vpc.private_subnets
  enable_irsa     = true

  tags = {
    ClusterName = local.name
    Environment = local.env
  }

  vpc_id = module.vpc.vpc_id

  workers_additional_policies = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"]

  worker_groups_launch_template = [
    {
      name                    = "spot"
      override_instance_types = var.worker_groups.spot.override_instance_types
      spot_instance_pools     = var.worker_groups.spot.spot_instance_pools
      asg_max_size            = var.worker_groups.spot.asg_max_size
      asg_min_size            = var.worker_groups.spot.asg_min_size
      asg_desired_capacity    = var.worker_groups.spot.asg_desired_capacity
      kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
      public_ip               = true
      additional_userdata     = file("${path.module}/templates/eks-nodes-userdata.sh")
      tags = [
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
    },
    {
      name                 = "ondemand"
      instance_type        = var.worker_groups.ondemand.instance_type
      asg_desired_capacity = var.worker_groups.ondemand.asg_desired_capacity
      asg_max_size         = var.worker_groups.ondemand.asg_max_size
      cpu_credits          = "unlimited"
      kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=ondemand"
      public_ip            = false
      additional_userdata  = file("${path.module}/templates/eks-nodes-userdata.sh")
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "true"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.name}"
          "propagate_at_launch" = "true"
          "value"               = "true"
        }
      ]
    },
    {
      name                    = "ci"
      override_instance_types = var.worker_groups.ci.override_instance_types
      spot_instance_pools     = var.worker_groups.ci.spot_instance_pools
      asg_max_size            = var.worker_groups.ci.asg_max_size
      asg_min_size            = var.worker_groups.ci.asg_min_size
      asg_desired_capacity    = var.worker_groups.ci.asg_desired_capacity
      cpu_credits             = "unlimited"
      kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot --node-labels=purpose=ci --register-with-taints=purpose=ci:NoSchedule"
      public_ip               = true
      additional_userdata     = file("${path.module}/templates/eks-nodes-userdata.sh")
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/label/purpose"
          "propagate_at_launch" = "true"
          "value"               = "ci"
        }
      ]
    },
  ]

  map_users = var.map_users
  #map_roles = var.map_roles

  write_kubeconfig = false
}
