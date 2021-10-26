variable "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  default     = ""
}
variable "name" {
  description = "Name, required to form unique resource names"
  default     = ""
}

variable "region" {
  description = "Target region for all infrastructure resources"
  default     = ""
}

variable "policy" {
  description = "The policy that will be attached to role"
}
