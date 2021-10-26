variable "name" {
  description = "Project name, required to form unique resource names"
  default     = ""
}

variable "policy" {
  description = "IAM policy that will be attached to user"
}
