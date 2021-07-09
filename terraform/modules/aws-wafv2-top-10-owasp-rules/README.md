There are 2 implementations of AWS WAF: AWS WAF Classic and AWS WAFv2. AWS recommends using AWS WAFv2 for new installations.  
This terraform module creates AWS WAFv2 rule-group with rules that cover *OWASP TOP 10 security issues* (https://d0.awsstatic.com/whitepapers/Security/aws-waf-owasp.pdf).  

For a CloudFront distribution, AWS WAF is available globally, but you must use the Region US East (N. Virginia) for all of your work. You must create your web ACL using the Region US East (N. Virginia). You must also use this Region to create any other resources that you use in your web ACL, like rule groups, IP sets, and regex pattern sets.  

Example of using this module: 
```bash
module "wafv2_owasp_top_10_rules" {
  source = "../modules/aws-wafv2-top-10-owasp-rules"

  name = "${var.name}-${local.env}"

  waf_scope = "CLOUDFRONT"

  max_expected_uri_size          = "512"
  max_expected_query_string_size = "1024"
  max_expected_body_size         = "4096"
  max_expected_cookie_size       = "4093"

  csrf_expected_header = "x-csrf-token"
  csrf_expected_size   = "36"

  cloudwatch_metrics_enabled = true
  blacklisted_cidrs          = ["10.0.0.0/8", "192.168.0.0/16", "169.254.0.0/16", "172.16.0.0/16", "127.0.0.1/32"]
}

resource "aws_wafv2_web_acl" "example" {
  name  = "${var.name}-${local.env}-webacl"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "owasp_top10_rules"
    priority = 1

    override_action {
      none {}
    }

    statement {
      rule_group_reference_statement {
        arn = module.wafv2_owasp_top_10_rules.rule_group_arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "owasp-top10-security-issues"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-${local.env}-webacl"
    sampled_requests_enabled   = false
  }
}

resource "aws_cloudfront_distribution" "example" {
  ...
  web_acl_id = aws_wafv2_web_acl.example.arn
  ...
}
```
