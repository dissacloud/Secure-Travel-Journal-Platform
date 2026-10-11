resource "aws_db_parameter_group" "postgresql" {
  name = "${var.name_prefix}-postgres17"

  family = "postgres17"

  description = "Security baseline for ${var.db_identifier}"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = {
    Name = "${var.name_prefix}-postgres17"
  }
}

resource "aws_db_subnet_group" "this" {
  name = "${var.name_prefix}-database"

  subnet_ids = var.database_subnet_ids

  description = "Isolated database subnets for ${var.db_identifier}"

  tags = {
    Name = "${var.name_prefix}-database"
  }
}

resource "aws_db_instance" "this" {
  identifier = var.db_identifier

  engine         = "postgres"
  engine_version = var.engine_version

  instance_class = var.instance_class

  db_name  = var.database_name
  username = var.master_username

  port = var.database_port

  manage_master_user_password = true

  master_user_secret_kms_key_id = aws_kms_key.master_secret.arn

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage

  storage_type      = "gp3"
  storage_encrypted = true

  kms_key_id = aws_kms_key.database_storage.arn

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = [
    aws_security_group.database.id
  ]

  publicly_accessible = false

  multi_az = var.multi_az

  parameter_group_name = aws_db_parameter_group.postgresql.name

  iam_database_authentication_enabled = true

  enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade",
    "iam-db-auth-error"
  ]

  monitoring_interval = var.monitoring_interval

  monitoring_role_arn = aws_iam_role.enhanced_monitoring.arn

  performance_insights_enabled = true

  performance_insights_kms_key_id = aws_kms_key.database_storage.arn

  backup_retention_period = var.backup_retention_days

  backup_window = "03:00-03:30"

  maintenance_window = "sun:04:00-sun:05:00"

  copy_tags_to_snapshot = true

  auto_minor_version_upgrade = true

  deletion_protection = var.deletion_protection

  skip_final_snapshot = var.skip_final_snapshot

  final_snapshot_identifier = (
    var.skip_final_snapshot
    ? null
    : "${var.db_identifier}-final"
  )

  delete_automated_backups = false

  apply_immediately = false

  depends_on = [
    aws_iam_role_policy_attachment.enhanced_monitoring,
    aws_cloudwatch_log_group.database
  ]

  tags = {
    Name = var.db_identifier
  }
}