resource "aws_instance" "ok" {
    ami =      "ami-00e801948462f718a"
instance_type = "t3.micro"
tags = {
    name = "ec2-instance"
}
}