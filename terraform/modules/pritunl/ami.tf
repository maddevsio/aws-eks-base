data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]


  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

}
