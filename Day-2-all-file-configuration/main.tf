resource "aws_instance" "babu"{
    ami = var.ami_id
    instance_type = var.instance_type
}