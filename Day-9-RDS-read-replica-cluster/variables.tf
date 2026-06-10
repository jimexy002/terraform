variable "aws_region" {
  description = "AWS region where the data tier will be created."
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Lowercase prefix used for resource names. Keep it short for RDS and ElastiCache identifier limits."
  type        = string
  default     = "day9-prod"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,24}[a-z0-9]$", var.name_prefix))
    error_message = "name_prefix must be 3-26 characters, lowercase, start with a letter, and contain only letters, numbers, and hyphens."
  }
}

variable "default_tags" {
  description = "Default tags applied to all supported AWS resources."
  type        = map(string)
  default = {
    Environment = "prod"
    ManagedBy   = "terraform"
    Project     = "day-9-rds-cache"
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the private data VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "data_subnet_cidrs" {
  description = "Private subnet CIDRs for RDS and ElastiCache. Use at least two CIDRs for Multi-AZ."
  type        = list(string)
  default     = ["10.40.20.0/24", "10.40.21.0/24"]

  validation {
    condition     = length(var.data_subnet_cidrs) >= 2
    error_message = "At least two data subnet CIDRs are required for production-style Multi-AZ resources."
  }
}

variable "db_name" {
  description = "Initial database name created on the primary RDS instance."
  type        = string
  default     = "appdb"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,62}$", var.db_name))
    error_message = "db_name must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "db_username" {
  description = "Master username for the RDS instance. The password is generated and managed by AWS Secrets Manager."
  type        = string
  default     = "adminuser"
}

variable "db_engine" {
  description = "RDS database engine."
  type        = string
  default     = "mysql"

  validation {
    condition     = var.db_engine == "mysql"
    error_message = "This example is tuned for mysql. Change the parameter group and log exports before using another engine."
  }
}

variable "db_engine_version" {
  description = "RDS MySQL engine version."
  type        = string
  default     = "8.0"
}

variable "db_parameter_group_family" {
  description = "RDS parameter group family matching the database engine version."
  type        = string
  default     = "mysql8.0"
}

variable "db_instance_class" {
  description = "Primary RDS instance class."
  type        = string
  default     = "db.t4g.medium"
}

variable "db_read_replica_instance_class" {
  description = "Read replica RDS instance class."
  type        = string
  default     = "db.t4g.medium"
}

variable "db_allocated_storage" {
  description = "Initial RDS storage in GiB."
  type        = number
  default     = 100
}

variable "db_max_allocated_storage" {
  description = "Maximum RDS autoscaled storage in GiB."
  type        = number
  default     = 500
}

variable "db_port" {
  description = "RDS database port."
  type        = number
  default     = 3306
}

variable "db_backup_retention_period" {
  description = "Number of days to retain RDS automated backups."
  type        = number
  default     = 14
}

variable "db_backup_window" {
  description = "Preferred RDS backup window in UTC."
  type        = string
  default     = "03:00-04:00"
}

variable "db_maintenance_window" {
  description = "Preferred RDS maintenance window in UTC."
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "db_read_replica_maintenance_window" {
  description = "Preferred RDS read replica maintenance window in UTC."
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "db_cloudwatch_log_exports" {
  description = "RDS log types exported to CloudWatch Logs."
  type        = list(string)
  default     = ["error", "general", "slowquery"]
}

variable "enhanced_monitoring_interval" {
  description = "Enhanced monitoring interval in seconds. Use 0 to disable."
  type        = number
  default     = 60
}

variable "performance_insights_enabled" {
  description = "Enable RDS Performance Insights."
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "RDS Performance Insights retention period in days."
  type        = number
  default     = 7
}

variable "iam_database_authentication_enabled" {
  description = "Enable IAM database authentication for RDS MySQL."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection for production data services."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshots when destroying RDS instances. Keep false for production."
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention period."
  type        = number
  default     = 90
}

variable "cache_engine_version" {
  description = "ElastiCache Redis engine version."
  type        = string
  default     = "7.1"
}

variable "cache_parameter_group_family" {
  description = "ElastiCache parameter group family."
  type        = string
  default     = "redis7"
}

variable "cache_node_type" {
  description = "ElastiCache node type."
  type        = string
  default     = "cache.t4g.small"
}

variable "cache_node_count" {
  description = "Total Redis nodes. Use 3 for one primary and two replicas."
  type        = number
  default     = 3

  validation {
    condition     = var.cache_node_count >= 2
    error_message = "cache_node_count must be at least 2 to support automatic failover."
  }
}

variable "cache_port" {
  description = "ElastiCache Redis port."
  type        = number
  default     = 6379
}

variable "cache_auth_token" {
  description = "Redis AUTH token. Use a strong value from a secure password manager; do not commit real secrets."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.cache_auth_token) >= 16 && length(var.cache_auth_token) <= 128
    error_message = "cache_auth_token must be between 16 and 128 characters."
  }
}

variable "cache_snapshot_retention_limit" {
  description = "Number of days to retain ElastiCache snapshots."
  type        = number
  default     = 7
}

variable "cache_snapshot_window" {
  description = "Preferred ElastiCache snapshot window in UTC."
  type        = string
  default     = "06:00-07:00"
}

variable "cache_maintenance_window" {
  description = "Preferred ElastiCache maintenance window in UTC."
  type        = string
  default     = "sun:06:00-sun:07:00"
}
