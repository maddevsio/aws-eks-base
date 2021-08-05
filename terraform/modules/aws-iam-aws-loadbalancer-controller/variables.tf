variable "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  default     = ""
}
variable "name" {
  description = "Project name, required to form unique resource names"
  default     = ""
}

variable "region" {
  description = "Target region for all infrastructure resources"
  default     = ""
}
