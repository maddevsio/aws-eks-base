variable "name" {
  type        = string
  default     = "example"
  description = ""
}

variable "common_name" {
  type        = string
  default     = "localhost"
  description = ""
}

variable "dns_names" {
  type        = list(any)
  default     = ["localhost"]
  description = ""
}

variable "validity_period_hours" {
  type        = string
  default     = 8760
  description = ""
}

variable "early_renewal_hours" {
  type        = string
  default     = 336
  description = ""
}
