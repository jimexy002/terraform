resource "aws_instance" "ok" {
  ami           = "ami-00e801948462f718a"
  instance_type = "t3.micro"

  tags = {
    Name = "ec2-instance"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/24"
}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/26"
}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.67/26"
}