
resource "aws_instance" "name" {
    ami           = "ami-00e801948462f718a"
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.name.id]
    subnet_id = aws_subnet.name.id
  
}

resource "aws_security_group" "name" {
  name        = "my-security-group"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.name.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}
}

resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "name" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a" 
}

resource "aws_s3_bucket" "name" {
  bucket = "mytestdtfrsrzztestdetv"
  depends_on = [aws_instance.name] # Ensure the EC2 instance is created before the S3 bucket
}