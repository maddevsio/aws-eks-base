data "aws_region" "current" {}
resource "aws_eip" "this" {
  vpc = true
  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

resource "aws_launch_template" "this" {
  name_prefix            = var.name
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  ebs_optimized          = false
  vpc_security_group_ids = [module.ec2_sg.security_group_id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.this_instance_profile.arn
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 3
  }

  user_data = base64encode(templatefile("${path.module}/templates/user-data.sh",
    {
      aws_region = data.aws_region.current.name
      eipalloc   = aws_eip.this.id
      efs_id     = aws_efs_file_system.this.id
    })
  )

  monitoring {
    enabled = false
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.name
    }
  }

  depends_on = [aws_efs_mount_target.this]

}

resource "aws_autoscaling_group" "this" {
  name                 = var.name
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  default_cooldown     = 30
  force_delete         = true
  termination_policies = ["OldestLaunchTemplate", "OldestInstance"]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.public_subnets

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
