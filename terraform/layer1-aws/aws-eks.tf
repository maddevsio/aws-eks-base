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
      override_instance_types = ["t3.medium", "t3a.medium"]
      spot_instance_pools     = 2
      asg_max_size            = 5
      asg_min_size            = 0
      asg_desired_capacity    = 1
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
      instance_type        = "t3a.medium"
      asg_desired_capacity = 1
      asg_max_size         = 6
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
      override_instance_types = ["t3a.medium", "t3.medium"]
      spot_instance_pools     = 2
      asg_max_size            = 3
      asg_desired_capacity    = 0
      asg_min_size            = 0
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
