variable "vpc_id" {}
variable "public_subnets" {}

variable "name" {
  default = "pritunl"
}
variable "environment" {
  default = "infra"
}
variable "instance_type" {
  default = "t3.small"
}

variable "encrypted" {
  default = true
}

variable "kms_key_id" {
  default = null
}
variable "ingress_with_source_security_group_id" {
  type = list(object({
    protocol        = string
    from_port       = string
    to_port         = string
    security_groups = string
  }))

  default = []
}
variable "ingress_with_cidr_blocks" {
  type = list(object({
    protocol    = string
    from_port   = string
    to_port     = string
    cidr_blocks = string
  }))

  default = []
}
