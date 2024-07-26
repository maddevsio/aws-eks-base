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

variable "validation_method" {
  default     = "DNS"
  description = "Which method to use for validation. DNS or EMAIL are valid. This parameter must not be set for certificates that were imported into ACM and then into Terraform."
}
