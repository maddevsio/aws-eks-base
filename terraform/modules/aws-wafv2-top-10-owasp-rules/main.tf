resource "aws_wafv2_ip_set" "owasp_10_detect_blacklisted_ips" {
  name               = "${var.name}-${lower(var.waf_scope)}-owasp-10-detect-blacklisted-ips"
  scope              = var.waf_scope
  ip_address_version = "IPV4"
  addresses          = var.blacklisted_cidrs
}

resource "aws_wafv2_rule_group" "owasp_top10_rules" {
  name     = "${var.name}-${lower(var.waf_scope)}-owasp-top10-security-issues"
  scope    = var.waf_scope
  capacity = 580

  rule {
    ## OWASP Top 10 A1
    ### Mitigate SQL Injection Attacks
    ### Matches attempted SQLi patterns in the URI, QUERY_STRING, BODY, COOKIES
    name     = "owasp-01-detect-sql-injection"
    priority = 1

    action {
      dynamic "count" {
        for_each = var.wafv2_rule_action == "count" ? [1] : []
        content {}
      }

      dynamic "block" {
        for_each = var.wafv2_rule_action == "block" ? [1] : []
        content {}
      }

      dynamic "allow" {
        for_each = var.wafv2_rule_action == "allow" ? [1] : []
        content {}
      }
    }

    statement {
      or_statement {
        statement {
          sqli_match_statement {
            field_to_match {
              uri_path {}
            }

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }

        statement {
          sqli_match_statement {
            field_to_match {
              query_string {}
            }

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }

        statement {
          sqli_match_statement {
            field_to_match {
              body {}
            }

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }

        statement {
          sqli_match_statement {
            field_to_match {
              single_header {
                name = "authorization"
              }
            }

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }

        statement {
          sqli_match_statement {
            field_to_match {
              single_header {
                name = "cookie"
              }
            }

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }

      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name                = "owasp-01-detect-sql-injection"
      sampled_requests_enabled   = false
    }

  }

  rule {
    ## OWASP Top 10 A2
    ### Blacklist bad/hijacked JWT tokens or session IDs
    ### Matches the specific values in the cookie or Authorization header for JWT it is sufficient to check the signature
    name     = "owasp-02-match-auth-token"
    priority = 2

    action {
      dynamic "count" {
        for_each = var.wafv2_rule_action == "count" ? [1] : []
        content {}
      }

      dynamic "block" {
        for_each = var.wafv2_rule_action == "block" ? [1] : []
        content {}
      }

      dynamic "allow" {
        for_each = var.wafv2_rule_action == "allow" ? [1] : []
        content {}
      }
    }

    statement {
      or_statement {
        statement {
          byte_match_statement {
            field_to_match {
              single_header {
                name = "cookie"
              }
            }

            search_string         = "example-session-id"
            positional_constraint = "CONTAINS"

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              single_header {
                name = "authorization"
              }
            }

            search_string         = ".TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ"
            positional_constraint = "ENDS_WITH"

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
          }
        }

      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name                = "owasp-02-match-auth-token"
      sampled_requests_enabled   = false
    }
  }

  rule {
    ## OWASP Top 10 A3
    ### Mitigate Cross Site Scripting Attacks
    ### Matches attempted XSS patterns in the URI, QUERY_STRING, BODY, COOKIES
    name     = "owasp-03-detect-xss"
    priority = 3

    action {
      dynamic "count" {
        for_each = var.wafv2_rule_action == "count" ? [1] : []
        content {}
      }

      dynamic "block" {
        for_each = var.wafv2_rule_action == "block" ? [1] : []
        content {}
      }

      dynamic "allow" {
        for_each = var.wafv2_rule_action == "allow" ? [1] : []
        content {}
      }
    }

    statement {
      or_statement {
        statement {
          xss_match_statement {
            field_to_match {
              uri_path {}
            }

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }

        statement {
          xss_match_statement {
            field_to_match {
              query_string {}
            }

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }

        statement {
          xss_match_statement {
            field_to_match {
              body {}
            }

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }

        statement {
          xss_match_statement {
            field_to_match {
              single_header {
                name = "cookie"
              }
            }

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }

      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name                = "owasp-03-detect-xss"
      sampled_requests_enabled   = false
    }
  }

  rule {
    ## OWASP Top 10 A4
    ### Path Traversal, LFI, RFI
    ### Matches request patterns designed to traverse filesystem paths, and include local or remote files
    name     = "owasp-04-match-rfi-lfi-traversal"
    priority = 4

    action {
      dynamic "count" {
        for_each = var.wafv2_rule_action == "count" ? [1] : []
        content {}
      }

      dynamic "block" {
        for_each = var.wafv2_rule_action == "block" ? [1] : []
        content {}
      }

      dynamic "allow" {
        for_each = var.wafv2_rule_action == "allow" ? [1] : []
        content {}
      }
    }

    statement {
      or_statement {
        statement {
          byte_match_statement {
            field_to_match {
              uri_path {}
            }

            search_string         = "../"
            positional_constraint = "CONTAINS"

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }

          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              query_string {}
            }

            search_string         = "../"
            positional_constraint = "CONTAINS"

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }

          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              uri_path {}
            }

            search_string         = "://"
            positional_constraint = "CONTAINS"

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }

          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              query_string {}
            }

            search_string         = "://"
            positional_constraint = "CONTAINS"

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }

          }
        }

      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name                = "owasp-04-match-rfi-lfi-traversal"
      sampled_requests_enabled   = false
    }
  }

  rule {
    # OWASP Top 10 A5
    # PHP Specific Security Misconfigurations
    # Matches request patterns designed to exploit insecure PHP/CGI configuration
    name     = "owasp-05-match-php-insecure-uri"
    priority = 5

    action {
      dynamic "count" {
        for_each = var.wafv2_rule_action == "count" ? [1] : []
        content {}
      }

      dynamic "block" {
        for_each = var.wafv2_rule_action == "block" ? [1] : []
        content {}
      }

      dynamic "allow" {
        for_each = var.wafv2_rule_action == "allow" ? [1] : []
        content {}
      }
    }

    statement {
      or_statement {
        statement {
          byte_match_statement {
            field_to_match {
              query_string {}
            }

            search_string         = "_SERVER["
            positional_constraint = "CONTAINS"

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              query_string {}
            }

            search_string         = "_ENV["
            positional_constraint = "CONTAINS"

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              query_string {}
            }

            search_string         = "_ENV["
            positional_constraint = "CONTAINS"

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              query_string {}
            }

            search_string         = "auto_prepend_file="
            positional_constraint = "CONTAINS"

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              query_string {}
            }

            search_string         = "auto_append_file="
            positional_constraint = "CONTAINS"

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              query_string {}
            }

            search_string         = "allow_url_include="
            positional_constraint = "CONTAINS"

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              query_string {}
            }

            search_string         = "disable_functions="
            positional_constraint = "CONTAINS"

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              query_string {}
            }

            search_string         = "open_basedir="
            positional_constraint = "CONTAINS"

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              query_string {}
            }

            search_string         = "safe_mode="
            positional_constraint = "CONTAINS"

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }

          }
        }

      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name                = "owasp-05-match-php-insecure-uri"
      sampled_requests_enabled   = false
    }
  }

  rule {
    ## OWASP Top 10 A7
    ### Mitigate abnormal requests via size restrictions
    ### Enforce consistent request hygene, limit size of key elements
    name     = "owasp-07-size-restrictions"
    priority = 6

    action {
      dynamic "count" {
        for_each = var.wafv2_rule_action == "count" ? [1] : []
        content {}
      }

      dynamic "block" {
        for_each = var.wafv2_rule_action == "block" ? [1] : []
        content {}
      }

      dynamic "allow" {
        for_each = var.wafv2_rule_action == "allow" ? [1] : []
        content {}
      }
    }

    statement {
      or_statement {
        statement {
          size_constraint_statement {
            field_to_match {
              uri_path {}
            }

            comparison_operator = "GT"
            size                = var.max_expected_uri_size

            text_transformation {
              priority = 1
              type     = "NONE"
            }
          }
        }

        statement {
          size_constraint_statement {
            field_to_match {
              query_string {}
            }

            comparison_operator = "GT"
            size                = var.max_expected_query_string_size

            text_transformation {
              priority = 1
              type     = "NONE"
            }
          }
        }

        statement {
          size_constraint_statement {
            field_to_match {
              body {}
            }

            comparison_operator = "GT"
            size                = var.max_expected_body_size

            text_transformation {
              priority = 1
              type     = "NONE"
            }
          }
        }

        statement {
          size_constraint_statement {
            field_to_match {
              single_header {
                name = "cookie"
              }
            }

            comparison_operator = "GT"
            size                = var.max_expected_cookie_size

            text_transformation {
              priority = 1
              type     = "NONE"
            }
          }
        }

      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name                = "owasp-07-size-restrictions"
      sampled_requests_enabled   = false
    }
  }

  rule {
    ## OWASP Top 10 A8
    ### CSRF token enforcement example
    ### Enforce the presence of CSRF token in request header
    name     = "owasp-08-csrf-token-size"
    priority = 7

    action {
      dynamic "count" {
        for_each = var.wafv2_rule_action == "count" ? [1] : []
        content {}
      }

      dynamic "block" {
        for_each = var.wafv2_rule_action == "block" ? [1] : []
        content {}
      }

      dynamic "allow" {
        for_each = var.wafv2_rule_action == "allow" ? [1] : []
        content {}
      }
    }

    statement {
      and_statement {
        statement {
          byte_match_statement {
            field_to_match {
              method {}
            }

            search_string         = "post"
            positional_constraint = "EXACTLY"

            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }

          }
        }

        statement {
          size_constraint_statement {
            field_to_match {
              single_header {
                name = var.csrf_expected_header
              }
            }

            comparison_operator = "EQ"
            size                = var.csrf_expected_size

            text_transformation {
              priority = 1
              type     = "NONE"
            }
          }
        }

      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name                = "owasp-08-csrf-token-size"
      sampled_requests_enabled   = false
    }
  }

  rule {
    ## OWASP Top 10 A9
    ### Server-side includes & libraries in webroot
    ### Matches request patterns for webroot objects that shouldn't be directly accessible
    name     = "owasp-09-match-ssi"
    priority = 8

    action {
      dynamic "count" {
        for_each = var.wafv2_rule_action == "count" ? [1] : []
        content {}
      }

      dynamic "block" {
        for_each = var.wafv2_rule_action == "block" ? [1] : []
        content {}
      }

      dynamic "allow" {
        for_each = var.wafv2_rule_action == "allow" ? [1] : []
        content {}
      }
    }

    statement {
      or_statement {
        statement {
          byte_match_statement {
            field_to_match {
              uri_path {}
            }

            search_string         = ".cfg"
            positional_constraint = "ENDS_WITH"

            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }

          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              uri_path {}
            }

            search_string         = ".conf"
            positional_constraint = "ENDS_WITH"

            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }

          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              uri_path {}
            }

            search_string         = ".config"
            positional_constraint = "ENDS_WITH"

            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }

          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              uri_path {}
            }

            search_string         = ".ini"
            positional_constraint = "ENDS_WITH"

            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }

          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              uri_path {}
            }

            search_string         = ".log"
            positional_constraint = "ENDS_WITH"

            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }

          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              uri_path {}
            }

            search_string         = ".bak"
            positional_constraint = "ENDS_WITH"

            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }

          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              uri_path {}
            }

            search_string         = ".backup"
            positional_constraint = "ENDS_WITH"

            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }

          }
        }

      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name                = "owasp-09-match-ssi"
      sampled_requests_enabled   = false
    }
  }

  rule {
    ## 10. ## Gs IP addresses that should not be allowed to access content
    name     = "owasp-10-detect-blacklisted-ips"
    priority = 9

    action {
      dynamic "count" {
        for_each = var.wafv2_rule_action == "count" ? [1] : []
        content {}
      }

      dynamic "block" {
        for_each = var.wafv2_rule_action == "block" ? [1] : []
        content {}
      }

      dynamic "allow" {
        for_each = var.wafv2_rule_action == "allow" ? [1] : []
        content {}
      }
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.owasp_10_detect_blacklisted_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name                = "owasp-10-detect-blacklisted-ips"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
    metric_name                = "${var.name}-${lower(var.waf_scope)}-owasp-top10-security-issues"
    sampled_requests_enabled   = false
  }
}
