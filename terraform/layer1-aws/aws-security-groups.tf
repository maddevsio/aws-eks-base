resource "aws_security_group" "rds" {
  name_prefix = "${local.name}-rds"
  description = "Allow inbound traffic to EKS from allowed ips and EKS workers"
  vpc_id      = module.vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "workers_to_rds" {
  description              = "Allow nodes to communicate with RDS."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = module.eks.worker_security_group_id
  from_port                = 3306
  to_port                  = 3306
  type                     = "ingress"
}
