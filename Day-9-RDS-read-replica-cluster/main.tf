data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  rds_primary_identifier           = "${var.name_prefix}-primary"
  rds_read_replica_identifier      = "${var.name_prefix}-read-1"
  elasticache_replication_group_id = "${var.name_prefix}-redis"
  elasticache_parameter_group_name = "${var.name_prefix}-redis-params"
  enhanced_monitoring_role_name    = "${var.name_prefix}-rds-monitoring"
  data_subnet_availability_zone_names = slice(
    data.aws_availability_zones.available.names,
    0,
    length(var.data_subnet_cidrs)
  )
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_subnet" "data" {
  count = length(var.data_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.data_subnet_cidrs[count.index]
  availability_zone       = local.data_subnet_availability_zone_names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-data-${count.index + 1}"
    Tier = "data"
  }
}

resource "aws_route_table" "data" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-data-rt"
  }
}

resource "aws_route_table_association" "data" {
  count = length(aws_subnet.data)

  subnet_id      = aws_subnet.data[count.index].id
  route_table_id = aws_route_table.data.id
}

resource "aws_kms_key" "data" {
  description             = "KMS key for ${var.name_prefix} RDS and ElastiCache encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name = "${var.name_prefix}-data-key"
  }
}

resource "aws_kms_alias" "data" {
  name          = "alias/${var.name_prefix}-data"
  target_key_id = aws_kms_key.data.key_id
}

resource "aws_cloudwatch_log_group" "rds_primary" {
  for_each = toset(var.db_cloudwatch_log_exports)

  name              = "/aws/rds/instance/${local.rds_primary_identifier}/${each.key}"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${local.rds_primary_identifier}-${each.key}"
  }
}

resource "aws_cloudwatch_log_group" "rds_read_replica" {
  for_each = toset(var.db_cloudwatch_log_exports)

  name              = "/aws/rds/instance/${local.rds_read_replica_identifier}/${each.key}"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${local.rds_read_replica_identifier}-${each.key}"
  }
}
