resource "aws_instance" "name" {
  ami = "ami-0521cb2d60cfbb1a6"
  instance_type = "t3.micro"
tags = {
  Name = "babu"
}
}
resource "aws_s3_bucket" "name" {
  bucket = "sahuuuuhuhuhduwdic"
}