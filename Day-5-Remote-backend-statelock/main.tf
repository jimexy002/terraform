resource "aws_instance" "ok" {
  ami           = "ami-00e801948462f718a"
  instance_type = "t3.micro"
}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/24"
}
resource "aws_vpc" "mai" {
  cidr_block = "10.0.0.0/26"
}