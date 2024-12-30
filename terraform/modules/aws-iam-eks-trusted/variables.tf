variable "oidc_provider_arn" {
  type        = string
  description = "The ARN of the OIDC Provider"
}

variable "name" {
  type        = string
  description = "Name, required to form unique resource names"
}

variable "region" {
  type        = string
  description = "Target region for all infrastructure resources"
}

variable "policy" {
  type        = string
  description = "The policy that will be attached to role"
}
