variable "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  type        = string
  default     = ""
}

variable "name" {
  description = "Project name, required to form unique resource names"
  default     = ""
}

# changed type from string to list
# to support multi-buckets
variable "bucket_names" {
  default     = []
  description = "Name of the bucket to store logs"
}

variable "path" {
  type    = string
  default = ""
}

variable "region" {
  description = "Target region for all infrastructure resources"
  default     = ""
}

variable "create_user" {
  type    = bool
  default = false
}

variable "create_role" {
  type    = bool
  default = true
}

variable "description" {
  type    = string
  default = ""
}
