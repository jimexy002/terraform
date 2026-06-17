terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ==============================================================================
# 1. NETWORKING (VPC & SUBNETS)
# ==============================================================================

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "private-db-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "vpc-igw" }
}

# Public Subnets (For NAT Gateway)
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = { Name = "public-subnet-${count.index}" }
}

# Private Subnets (For Lambda & RDS)
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = { Name = "private-subnet-${count.index}" }
}

resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

# 
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/12"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/12"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "private-rt" }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# ==============================================================================
# 2. VPC ENDPOINTS (PRIVATELINK)
# ==============================================================================

# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoints-sg"
  description = "Allow private traffic to VPC Endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from within VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Secrets Manager Endpoint
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = true

  tags = { Name = "secretsmanager-vpce" }
}

# Lambda Endpoint
resource "aws_vpc_endpoint" "lambda" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.lambda"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = true

  tags = { Name = "lambda-vpce" }
}

# ==============================================================================
# 3. SECURE RDS MYSQL DATABASE
# ==============================================================================

resource "aws_db_subnet_group" "db_subnets" {
  name       = "rds-private-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  tags       = { Name = "DB Subnet Group" }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-mysql-sg"
  description = "Allow MySQL traffic from Lambda"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from Lambda Function"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "mysql" {
  identifier           = "private-mysql-instance"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro" # Free-tier eligible
  allocated_storage    = 20
  max_allocated_storage = 100
  storage_type         = "gp3"
  
  db_name              = "appdb"
  username             = "dbadmin"

  # Active Native AWS Secrets Manager Integration
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = { Name = "private-mysql-db" }
}

# ==============================================================================
# 4. LAMBDA FUNCTION CONFIGURATION
# ==============================================================================

resource "aws_security_group" "lambda_sg" {
  name        = "lambda-vpc-sg"
  description = "Security group for Lambda within private subnets"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Lambda Execution Role & Managed Policies
resource "aws_iam_role" "lambda_role" {
  name = "lambda-rds-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Attach basic execution for CloudWatch Logs + VPC configurations
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Custom IAM Policy to grant access to the dynamically generated RDS Secret
resource "aws_iam_policy" "lambda_secret_policy" {
  name        = "lambda-secretsmanager-rds-policy"
  description = "Allows Lambda to get the RDS Master User secret details"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [aws_db_instance.mysql.master_user_secret[0].secret_arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_secrets_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_secret_policy.arn
}

# Dummy local script file generation for Lambda function payload
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"

  source {
    content  = <<EOF
import json
import boto3
import os

def lambda_handler(event, context):
    secret_arn = os.environ['SECRET_ARN']
    db_endpoint = os.environ['DB_ENDPOINT']
    
    # Initialize internal Secrets Manager client
    client = boto3.client('secretsmanager')
    
    try:
        response = client.get_secret_value(SecretId=secret_arn)
        credentials = json.loads(response['SecretString'])
        
        # Pull generated components safely
        username = credentials['username']
        password = credentials['password']
        
        print(f"Successfully retrieved credentials for {username}")
        print(f"Target Private Database Endpoint: {db_endpoint}")
        
        # Connect to DB string processing can go here safely...
        return {
            'statusCode': 200,
            'body': json.dumps('Successfully fetched secrets internally!')
        }
    except Exception as e:
        print(e)
        raise e
EOF
    filename = "index.py"
  }
}

resource "aws_lambda_function" "rds_connector" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "rds-private-connector"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.11"
  timeout          = 30

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      SECRET_ARN  = aws_db_instance.mysql.master_user_secret[0].secret_arn
      DB_ENDPOINT = aws_db_instance.mysql.endpoint
    }
  }

  depends_on = [
    aws_vpc_endpoint.secretsmanager, 
    aws_vpc_endpoint.lambda
  ]
}