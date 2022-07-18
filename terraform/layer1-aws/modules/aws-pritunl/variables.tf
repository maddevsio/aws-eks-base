variable "vpc_id" {
  type        = string
  description = "ID of the VPC where to create security groups"
}

variable "public_subnets" {
  type        = list(any)
  description = "A list of public subnets where Pritunl server will be run"
}

variable "private_subnets" {
  type        = list(any)
  description = "A list of private subnets where EFS will be created"
}

variable "name" {
  default     = "pritunl"
  description = "Name used for all resources in this module"
}

variable "environment" {
  default     = "infra"
  description = "Environment name"
}

variable "instance_type" {
  default     = "t3.small"
  description = "Pritunl server instance type"
}

variable "encrypted" {
  default     = true
  description = "Encrypt or not EFS"
}

variable "kms_key_id" {
  default     = null
  description = "KMS key ID in case of using CMK"
}

variable "ingress_with_source_security_group_id" {
  type = list(object({
    protocol        = string
    from_port       = string
    to_port         = string
    security_groups = string
  }))

  default     = []
  description = "A list of Pritunl server security group rules where source is another security group"
}

variable "ingress_with_cidr_blocks" {
  type = list(object({
    protocol    = string
    from_port   = string
    to_port     = string
    cidr_blocks = string
  }))

  default     = []
  description = "A list of Pritunl server security group rules where source is CIDR"
}
