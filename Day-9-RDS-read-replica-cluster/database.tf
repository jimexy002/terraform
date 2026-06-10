resource "aws_db_subnet_group" "database" {
  name       = "${var.name_prefix}-db-subnets"
  subnet_ids = aws_subnet.data[*].id

  tags = {
    Name = "${var.name_prefix}-db-subnets"
  }
}

resource "aws_db_parameter_group" "mysql" {
  name   = "${var.name_prefix}-mysql-params"
  family = var.db_parameter_group_family

  parameter {
    name         = "slow_query_log"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "long_query_time"
    value        = "2"
    apply_method = "immediate"
  }

  parameter {
    name         = "log_output"
    value        = "FILE"
    apply_method = "immediate"
  }

  tags = {
    Name = "${var.name_prefix}-mysql-params"
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = local.enhanced_monitoring_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = local.enhanced_monitoring_role_name
  }
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "primary" {
  identifier = local.rds_primary_identifier

  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.data.arn

  db_name  = var.db_name
  username = var.db_username
  port     = var.db_port

  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.data.arn

  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = true

  backup_retention_period  = var.db_backup_retention_period
  backup_window            = var.db_backup_window
  maintenance_window       = var.db_maintenance_window
  copy_tags_to_snapshot    = true
  delete_automated_backups = false

  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  apply_immediately           = false
  deletion_protection         = var.deletion_protection
  skip_final_snapshot         = var.skip_final_snapshot
  final_snapshot_identifier   = var.skip_final_snapshot ? null : "${local.rds_primary_identifier}-final"

  parameter_group_name                = aws_db_parameter_group.mysql.name
  enabled_cloudwatch_logs_exports     = var.db_cloudwatch_log_exports
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  monitoring_interval = var.enhanced_monitoring_interval
  monitoring_role_arn = var.enhanced_monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring.arn : null

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? aws_kms_key.data.arn : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  tags = {
    Name = local.rds_primary_identifier
    Role = "writer"
  }

  depends_on = [
    aws_cloudwatch_log_group.rds_primary,
    aws_iam_role_policy_attachment.rds_enhanced_monitoring
  ]
}

resource "aws_db_instance" "read_replica" {
  identifier          = local.rds_read_replica_identifier
  replicate_source_db = aws_db_instance.primary.identifier

  instance_class         = var.db_read_replica_instance_class
  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  availability_zone      = local.data_subnet_availability_zone_names[1]
  parameter_group_name   = aws_db_parameter_group.mysql.name

  maintenance_window       = var.db_read_replica_maintenance_window
  copy_tags_to_snapshot    = true
  delete_automated_backups = false

  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  apply_immediately           = false
  deletion_protection         = var.deletion_protection
  skip_final_snapshot         = var.skip_final_snapshot
  final_snapshot_identifier   = var.skip_final_snapshot ? null : "${local.rds_read_replica_identifier}-final"

  enabled_cloudwatch_logs_exports = var.db_cloudwatch_log_exports

  monitoring_interval = var.enhanced_monitoring_interval
  monitoring_role_arn = var.enhanced_monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring.arn : null

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? aws_kms_key.data.arn : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  tags = {
    Name = local.rds_read_replica_identifier
    Role = "reader"
  }

  depends_on = [
    aws_cloudwatch_log_group.rds_read_replica,
    aws_iam_role_policy_attachment.rds_enhanced_monitoring
  ]
}
