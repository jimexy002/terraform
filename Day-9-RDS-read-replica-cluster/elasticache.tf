resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.name_prefix}-redis-subnets"
  subnet_ids = aws_subnet.data[*].id

  tags = {
    Name = "${var.name_prefix}-redis-subnets"
  }
}

resource "aws_elasticache_parameter_group" "redis" {
  name   = local.elasticache_parameter_group_name
  family = var.cache_parameter_group_family

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  tags = {
    Name = local.elasticache_parameter_group_name
  }
}

resource "aws_cloudwatch_log_group" "redis_slow" {
  name              = "/aws/elasticache/${local.elasticache_replication_group_id}/slow-log"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${local.elasticache_replication_group_id}-slow-log"
  }
}

resource "aws_cloudwatch_log_group" "redis_engine" {
  name              = "/aws/elasticache/${local.elasticache_replication_group_id}/engine-log"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${local.elasticache_replication_group_id}-engine-log"
  }
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = local.elasticache_replication_group_id
  description          = "Redis replication group for ${var.name_prefix}"

  engine         = "redis"
  engine_version = var.cache_engine_version
  node_type      = var.cache_node_type
  port           = var.cache_port

  num_cache_clusters         = var.cache_node_count
  automatic_failover_enabled = true
  multi_az_enabled           = true

  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]
  parameter_group_name = aws_elasticache_parameter_group.redis.name

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = var.cache_auth_token
  kms_key_id                 = aws_kms_key.data.arn

  snapshot_retention_limit  = var.cache_snapshot_retention_limit
  snapshot_window           = var.cache_snapshot_window
  maintenance_window        = var.cache_maintenance_window
  final_snapshot_identifier = "${local.elasticache_replication_group_id}-final"

  auto_minor_version_upgrade = true
  apply_immediately          = false

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_slow.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_engine.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  tags = {
    Name = local.elasticache_replication_group_id
    Role = "cache"
  }
}
