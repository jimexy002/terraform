
resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "name" {
    vpc_id            = aws_vpc.name.id
    cidr_block        = "10.0.0.0/24"
}


resource "aws_security_group" "name" {
    name        = "my-security-group"
    description = "Security group with multiple inbound rules from same source"
    vpc_id      = aws_vpc.name.id
 
 # we can use for loop to create multiple ingress rules with same source but different ports
    ingress = [
     for port in var.sgrule : {

        description      = "Allow HTTP traffic from anywhere"
        from_port        = port
        to_port          = port
        ipv6_cidr_blocks = []
        prefix_list_ids  = []
        security_groups   = []
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
        self             = false
    
    }
    ]
}

resource "aws_instance" "name" {
    ami           = "ami-00e801948462f718a"
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.name.id]
    subnet_id = aws_subnet.name.id
    tags = {
        Name = "my-ec2-instance"
    }
}