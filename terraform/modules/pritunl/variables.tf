variable vpc_id {}
variable public_subnets {}
variable availability_zone {
  default = "us-east-1a"
}
variable name {
  default = "pritunl"
}
variable environment {
  default = "infra"
}
variable instance_type {
  default = "t3.small"
}

variable "pritunl_sg_rules" {
  type = list(object({
    protocol    = string
    from_port   = string
    to_port     = string
    cidr_blocks = list(string)
  }))

  default = []
}
