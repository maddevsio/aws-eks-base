variable "namespace" {
  type        = string
  default     = "ci"
  description = "description"
}

variable "name" {
  type        = string
  default     = "gitlab-executor"
  description = "description"
}

variable "role_arn" {
  type        = string
  default     = ""
  description = "OpenID Connect role arn"
}
