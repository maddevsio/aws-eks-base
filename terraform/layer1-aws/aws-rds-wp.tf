module "db_wp" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = local.wp_db_name

  engine            = "mysql"
  engine_version    = "5.7.26"
  instance_class    = var.rds_instance_wp
  allocated_storage = 10
  storage_encrypted = true

  name                                = local.wp_db_database
  username                            = local.wp_db_username
  password                            = local.wp_db_password
  port                                = "3306"
  iam_database_authentication_enabled = true
  vpc_security_group_ids              = [aws_security_group.rds.id]
  subnet_ids                          = module.vpc.database_subnets
  auto_minor_version_upgrade          = false

  maintenance_window      = "Sun:00:00-Sun:03:00"
  backup_window           = "03:00-06:00"
  monitoring_interval     = "30"
  monitoring_role_name    = local.wp_db_name
  create_monitoring_role  = true
  multi_az                = false
  backup_retention_period = 0

  enabled_cloudwatch_logs_exports = ["audit", "general", "slowquery"]

  family                    = "mysql5.7"
  major_engine_version      = "5.7"
  final_snapshot_identifier = local.wp_db_name
  deletion_protection       = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8"
    },
    {
      name  = "character_set_server"
      value = "utf8"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]

  tags = {
    Name        = local.wp_db_name
    Environment = "dev"
  }
}
