variable "wafv2_rule_action" {
  type        = string
  default     = "block"
  description = "Default rules action"
}

variable "waf_scope" {
  type        = string
  default     = "CLOUDFRONT"
  description = "One API can be used for both global and regional applications. Possible values are CLOUDFRONT and REGIONAL. REGIONAL is used for ALBs, API Gateway"
}

variable "name" {
  type        = string
  description = "Name used for all resources in this module"
}

variable "max_expected_uri_size" {
  type        = string
  default     = "512"
  description = "Maximum number of bytes allowed in the URI component of the HTTP request. Generally the maximum possible value is determined by the server operating system (maps to file system paths), the web server software, or other middleware components. Choose a value that accomodates the largest URI segment you use in practice in your web application."
}

variable "max_expected_query_string_size" {
  type        = string
  default     = "1024"
  description = "Maximum number of bytes allowed in the query string component of the HTTP request. Normally the  of query string parameters following the ? in a URL is much larger than the URI , but still bounded by the  of the parameters your web application uses and their values."
}

variable "max_expected_body_size" {
  type        = string
  default     = "4096"
  description = "Maximum number of bytes allowed in the body of the request. If you do not plan to allow large uploads, set it to the largest payload value that makes sense for your web application. Accepting unnecessarily large values can cause performance issues, if large payloads are used as an attack vector against your web application."
}

variable "max_expected_cookie_size" {
  type        = string
  default     = "4093"
  description = "Maximum number of bytes allowed in the cookie header. The maximum size should be less than 4096, the size is determined by the amount of information your web application stores in cookies. If you only pass a session token via cookies, set the size to no larger than the serialized size of the session token and cookie metadata."
}

variable "csrf_expected_header" {
  type        = string
  default     = "x-csrf-token"
  description = "The custom HTTP request header, where the CSRF token value is expected to be encountered"
}

variable "csrf_expected_size" {
  type        = string
  default     = "36"
  description = "The size in bytes of the CSRF token value. For example if it's a canonically formatted UUIDv4 value the expected size would be 36 bytes/ASCII characters."
}

variable "blacklisted_cidrs" {
  type        = list(string)
  default     = ["10.0.0.0/8", "192.168.0.0/16", "169.254.0.0/16", "172.16.0.0/16", "127.0.0.1/32"]
  description = "A list of blacklister CIDR blocks"
}

variable "cloudwatch_metrics_enabled" {
  type        = bool
  default     = false
  description = "Enable or not using AWS Cloudwatch metrics"
}
