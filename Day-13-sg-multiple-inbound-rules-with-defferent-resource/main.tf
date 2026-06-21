variable "allowed_ports" {
    type = map(string)
    default = {
    #key = value
    22    = "203.0.113.0/24"    # SSH (Restrict to office IP)
    80    = "0.0.0.0/0"         # HTTP (Public)
    443   = "0.0.0.0/0"         # HTTPS (Public)
    8080  = "10.0.0.0/16"       # Internal App (Restrict to VPC)
    9000  = "192.168.1.0/24"    # SonarQube/Jenkins (Restrict to VPN)
    3389  = "10.0.1.0/24"
    3000  = "10.0.2.0/24"
    #we can add port number and irrespective of cidr in future ref 

  }
}

  
resource "aws_security_group" "devops-project-veera" {
  name        = "devops-project-veera-nit"
  description = "Allow TLS inbound traffic"

  

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      description = "Allow access to port ${ingress.key}"
      from_port   = ingress.key #here key is the port number and value is the source CIDR block
      to_port     = ingress.key
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
     
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-project-veera-nit"
  }
}