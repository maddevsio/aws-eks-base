variable "name" {
  type        = string
  description = "Name, required to create unique resource names"
}

variable "cidr" {
  type        = string
  description = "The IPv4 CIDR block for the VPC"
}

variable "azs" {
  type        = list(any)
  description = "A list of availability zones names or ids in the region"
}

variable "single_nat_gateway" {
  type        = bool
  default     = false
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
}

variable "tags" {
  type        = any
  default     = {}
  description = "A map of additional tags to add to resources"
}
