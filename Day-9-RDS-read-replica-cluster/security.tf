resource "aws_security_group" "application" {
  name        = "${var.name_prefix}-app-sg"
  description = "Attach to application compute that needs RDS and Redis access"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-app-sg"
    Role = "application-client"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Allow MySQL access from application security group only"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-rds-sg"
    Role = "database"
  }
}

resource "aws_security_group" "redis" {
  name        = "${var.name_prefix}-redis-sg"
  description = "Allow Redis access from application security group only"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-redis-sg"
    Role = "cache"
  }
}

resource "aws_security_group_rule" "app_to_rds" {
  type                     = "egress"
  description              = "Application outbound to RDS MySQL"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application.id
  source_security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rds_from_app" {
  type                     = "ingress"
  description              = "RDS MySQL inbound from application"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.application.id
}

resource "aws_security_group_rule" "app_to_redis" {
  type                     = "egress"
  description              = "Application outbound to Redis"
  from_port                = var.cache_port
  to_port                  = var.cache_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application.id
  source_security_group_id = aws_security_group.redis.id
}

resource "aws_security_group_rule" "redis_from_app" {
  type                     = "ingress"
  description              = "Redis inbound from application"
  from_port                = var.cache_port
  to_port                  = var.cache_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis.id
  source_security_group_id = aws_security_group.application.id
}
