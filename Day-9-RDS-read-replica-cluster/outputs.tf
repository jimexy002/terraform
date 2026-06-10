output "vpc_id" {
  description = "VPC ID for the private data tier."
  value       = aws_vpc.main.id
}

output "data_subnet_ids" {
  description = "Private subnet IDs used by RDS and ElastiCache."
  value       = aws_subnet.data[*].id
}

output "application_security_group_id" {
  description = "Attach this security group to application servers that need DB and Redis access."
  value       = aws_security_group.application.id
}

output "rds_primary_endpoint" {
  description = "Primary RDS writer endpoint."
  value       = aws_db_instance.primary.endpoint
}

output "rds_read_replica_endpoint" {
  description = "RDS read replica endpoint."
  value       = aws_db_instance.read_replica.endpoint
}

output "rds_master_secret_arn" {
  description = "Secrets Manager ARN containing the generated RDS master password."
  value       = aws_db_instance.primary.master_user_secret[0].secret_arn
  sensitive   = true
}

output "elasticache_primary_endpoint" {
  description = "Primary Redis endpoint."
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "elasticache_reader_endpoint" {
  description = "Redis reader endpoint."
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}
