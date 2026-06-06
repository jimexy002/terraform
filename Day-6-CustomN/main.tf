#Creation of vpc
resource "aws_vpc" "main" {
cidr_block = "10.0.0.0/16"
tags = {
  name = "bab vpc"
}
}

#Creation of public subnet
resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
cidr_block = "10.0.0.0/24"
availability_zone = "us-west-1a"
tags = {
  name = "bab-subnet"
}
}

#Creation of private subnet
resource "aws_subnet" "main2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-1c"
  tags ={
    name = "subnet2"
}
}

#Creation of internetgateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    name = "bab-igw"
  }
}

#Creation of Routetable
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    name = "bab-rt"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}
#association of routetable with public subnet
resource "aws_route_table_association" "main" {
  subnet_id = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}
resource "aws_security_group" "main" {
  name = "babu-sg"
  description = "Allow SSH and HTTP Traffic"
  vpc_id = aws_vpc.main.id

//inbound
  ingress   {
        from_port = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }
  ingress   {
        from_port = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }
//outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create of ec2 instance in public subnet
resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  tags = {
    name = var.name
  }
}