output "rds_endpoint" {
  value       = aws_db_instance.mysql.endpoint
  description = "The completely private endpoint of your MySQL DB"
}

output "secrets_manager_secret_arn" {
  value       = aws_db_instance.mysql.master_user_secret[0].secret_arn
  description = "The ARN of the AWS-managed secret setup for RDS"
}

output "lambda_function_name" {
  value       = aws_lambda_function.rds_connector.function_name
  description = "Name of the generated private Lambda function"
}