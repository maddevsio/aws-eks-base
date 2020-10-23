data "aws_region" "current" {}
data "aws_availability_zones" "available" {}
data "aws_subnet_ids" "selected" {
  # availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id = var.vpc_id
  filter {
    name   = "availabilityZone"
    values = [data.aws_availability_zones.available.names[0]] # insert values here
  }
}
resource "aws_ebs_volume" "mongodb_data" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = 10

  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

resource "aws_eip" "this" {
  vpc = true
  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

data "template_file" "userdata_script" {
  template = file("${path.module}/templates/user-data.sh")

  vars = {
    aws_region = data.aws_region.current.name
    eipalloc   = aws_eip.this.id
    volume_id  = aws_ebs_volume.mongodb_data.id
  }
}

resource "aws_launch_template" "this" {
  name_prefix            = var.name
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  ebs_optimized          = false
  vpc_security_group_ids = [aws_security_group.this.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.this_instance_profile.arn
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 3
  }

  user_data = base64encode(data.template_file.userdata_script.rendered)

  monitoring {
    enabled = false
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.name
    }
  }

}

resource "aws_autoscaling_group" "this" {
  name                 = var.name
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  default_cooldown     = 30
  force_delete         = true
  termination_policies = ["OldestLaunchConfiguration", "OldestInstance"]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  # availability_zones            = [var.availability_zone]
  vpc_zone_identifier = [tolist(data.aws_subnet_ids.selected.ids)[0]]
  # vpc_zone_identifier           = ["subnet-01ea79f020ac51979"]
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
