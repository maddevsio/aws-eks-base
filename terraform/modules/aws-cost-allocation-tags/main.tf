resource "aws_ce_cost_allocation_tag" "this" {
  for_each = { for item in var.tags : item.tag_key => item }

  tag_key = each.value.tag_key
  status  = each.value.status
}
