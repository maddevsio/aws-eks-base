variable "create_acm_certificate" {
  type    = bool
  default = false
}

variable "domain_name" {
  type        = string
  description = "Main public domain name"
}

variable "zone_id" {
  default     = ""
  description = "R53 zone id for public domain"
}
