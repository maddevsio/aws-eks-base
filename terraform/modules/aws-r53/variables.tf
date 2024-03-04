variable "domain_name" {
  type        = string
  description = "Main public domain name"
}

variable "create_r53_zone" {
  type        = bool
  default     = false
  description = "Create R53 zone for main public domain"
}

