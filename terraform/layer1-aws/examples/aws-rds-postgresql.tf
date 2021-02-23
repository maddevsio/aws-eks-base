# RDS Variables
variable "rds_instance" {
  type        = string
  default     = "db.t3.micro"
  description = "Instance class of the rds database"
}

locals {
  # Passwords for services and secrets
  db_password = random_string.postgres_password.result
  # Changed to production values because when restore db from production snapshot, db name and username changed.
  db_database = "d${random_string.postgres_database.result}"
  db_username = "u${random_string.postgres_user.result}"
  db_name     = local.name
}

resource "random_string" "postgres_password" {
  length  = 20
  special = false
}

resource "random_string" "postgres_database" {
  length  = 8
  special = false
}

resource "random_string" "postgres_user" {
  length  = 8
  special = false
}

resource "aws_security_group" "rds" {
  name_prefix = "${local.name}-rds"
  description = "Allow inbound traffic to EKS from allowed ips and EKS workers"
  vpc_id      = module.vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "workers_to_rds" {
  description              = "Allow nodes to communicate with RDS."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = module.eks.worker_security_group_id
  from_port                = 5432
  to_port                  = 5432
  type                     = "ingress"
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "2.20.0"

  identifier = local.db_name

  engine            = "postgres"
  engine_version    = "12.5"
  instance_class    = var.rds_instance
  allocated_storage = 30
  storage_encrypted = true

  name                                = local.db_database
  username                            = local.db_username
  password                            = local.db_password
  port                                = "5432"
  iam_database_authentication_enabled = false
  vpc_security_group_ids              = [aws_security_group.rds.id]
  subnet_ids                          = module.vpc.database_subnets
  auto_minor_version_upgrade          = false

  maintenance_window      = "Sun:00:00-Sun:03:00"
  backup_window           = "03:00-06:00"
  monitoring_interval     = "30"
  monitoring_role_name    = local.db_name
  create_monitoring_role  = true
  multi_az                = false
  backup_retention_period = 0

  family                    = "postgres12"
  major_engine_version      = "12"
  final_snapshot_identifier = local.db_name
  deletion_protection       = false

  #snapshot_identifier	    = var.stage_snapshot_identifier

  tags = {
    Name        = local.db_name
    Environment = local.env
  }
}

resource "aws_s3_bucket" "rds_backups" {
  bucket = "${local.name}-rds-backup"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    id      = "postgresql-backups-lifecycle-rule"
    enabled = false

    tags = {
      "rule" = "postgresql-backups-lifecycle-rule"
    }

    transition {
      days          = 365
      storage_class = "GLACIER"
    }
  }

  tags = {
    Name        = "${local.name}-rds-backups"
    Environment = local.env
  }
}

resource "aws_s3_bucket_public_access_block" "rds_backups" {
  bucket = aws_s3_bucket.rds_backups.id

  # Block new public ACLs and uploading public objects
  block_public_acls = true
  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true
  # Block new public bucket policies
  block_public_policy = true
  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}

module "aws_iam_rds_backups" {
  source = "../modules/aws-iam-s3"

  name              = "${local.name}-rds-backups"
  region            = var.region
  bucket_names      = [aws_s3_bucket.rds_backups.id]
  oidc_provider_arn = module.eks.oidc_provider_arn
  create_user       = true
}

module "ssm" {
  source = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=0.4.1"

  parameter_write = [
    {
      name      = "/${local.name_wo_region}/env/pg_host"
      value     = module.db.this_db_instance_address
      type      = "String"
      overwrite = "true"
    },
    {
      name      = "/${local.name_wo_region}/env/pg_port"
      value     = 5432
      type      = "String"
      overwrite = "true"
    },
    {
      name      = "/${local.name_wo_region}/env/pg_user"
      value     = local.db_username
      type      = "String"
      overwrite = "true"
    },
    {
      name      = "/${local.name_wo_region}/env/pg_database"
      value     = local.db_database
      type      = "String"
      overwrite = "true"
    },
    {
      name      = "/${local.name_wo_region}/env/pg_pass"
      value     = local.db_password
      type      = "String"
      overwrite = "true"
    },
    {
      name      = "/${local.name_wo_region}/env/s3/pg_backups_bucket_name"
      value     = aws_s3_bucket.rds_backups.id
      type      = "String"
      overwrite = "true"
    },
    {
      name      = "/${local.name_wo_region}/env/s3/pg_backups_bucket_region"
      value     = aws_s3_bucket.rds_backups.region
      type      = "String"
      overwrite = "true"
    },
    {
      name      = "/${local.name_wo_region}/env/s3/access_key_id"
      value     = module.aws_iam_rds_backups.access_key_id
      type      = "String"
      overwrite = "true"
    },
    {
      name      = "/${local.name_wo_region}/env/s3/access_secret_key"
      value     = module.aws_iam_rds_backups.access_secret_key
      type      = "String"
      overwrite = "true"
    }
  ]

  tags = {
    ManagedBy = "Terraform"
  }
}

output "db" {
  description = "description"
  value = {
    "username" = local.db_username
    "database" = local.db_database
    "password" = local.db_password
    "address"  = module.db.this_db_instance_address
  }
}




