
variable "env" {
   type = list(string)
   default = [ "dev","test","prod" ]
  
}

resource "aws_instance" "name" {
    ami = "ami-00e801948462f718a"
    instance_type = "t2.micro"
    #count = 2
    count = length(var.env)

    tags = {
      Name = var.env[count.index]
    }
  
}