variable "tags" {
  type = list(object({
    tag_key = string
    status  = string
  }))
  description = "A list of tags to use for cost allocation tags"
}
