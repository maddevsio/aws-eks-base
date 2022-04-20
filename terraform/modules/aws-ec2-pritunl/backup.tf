resource "aws_backup_vault" "this" {
  name = var.name
}

resource "aws_backup_plan" "this" {
  name = "${var.name}_backup_plan"
  rule {
    rule_name         = "${var.name}_backup_plan_efs"
    target_vault_name = aws_backup_vault.this.name
    schedule          = "cron(0 1 * * ? *)"
    lifecycle {
      delete_after = 30
    }
  }
}

resource "aws_backup_selection" "efs" {
  iam_role_arn = module.backup_role.iam_role_arn
  name         = "${var.name}_backup_selection_efs"
  plan_id      = aws_backup_plan.this.id

  resources = [
    aws_efs_file_system.this.arn
  ]
}
