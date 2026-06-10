# Production RDS Read Replica And ElastiCache

This folder creates a production-style private data tier:

- A dedicated VPC with private data subnets across multiple Availability Zones.
- RDS MySQL primary instance with Multi-AZ, encryption, backups, logs, enhanced monitoring, Performance Insights, and AWS-managed master password in Secrets Manager.
- RDS MySQL read replica for read scaling.
- ElastiCache Redis replication group with automatic failover, Multi-AZ, encryption at rest, encryption in transit, AUTH token, snapshots, and CloudWatch log delivery.
- Security groups that allow database and cache access only from the exported application security group.

## Files

- `provider.tf` configures Terraform and the AWS provider.
- `main.tf` creates the VPC, private subnets, KMS key, and log groups.
- `security.tf` creates security groups and access rules.
- `database.tf` creates the RDS primary instance and read replica.
- `elasticache.tf` creates the Redis replication group.
- `variables.tf` defines all input variables.
- `outputs.tf` prints connection endpoints and useful resource IDs.
- `terraform.tfvars.example` shows sample variable values.

## Commands

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set a real cache_auth_token.
terraform init
terraform plan
terraform apply
```

Attach the output `application_security_group_id` to your EC2, ECS, EKS, or other application compute that needs access to MySQL and Redis.

## Important

This is production-shaped infrastructure and can create billable AWS resources. `deletion_protection` is enabled by default, so set it to `false` before destroying the RDS instances.
