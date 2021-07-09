output "rule_group_arn" {
  value = aws_wafv2_rule_group.owasp_top10_rules.arn
}
