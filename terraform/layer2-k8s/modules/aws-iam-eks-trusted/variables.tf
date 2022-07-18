variable "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
}

variable "name" {
  description = "Name, required to form unique resource names"
}

variable "region" {
  description = "Target region for all infrastructure resources"
}

variable "policy" {
  description = "The policy that will be attached to role"
}
