resource "aws_instance" "insta" {
    ami =      "ami-055fa94f88d629cc9"
instance_type = "t2.micro"
tags = {
    name = "nit"
}
}