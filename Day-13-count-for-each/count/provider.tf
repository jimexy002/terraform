
variable "env" {
   type = list(string)
   default = [ "dev","prod" ]
  
}

resource "aws_instance" "name" {
    ami = ""
    instance_type = "t3.micro"
    for_each = toset(var.env)

    tags = {
      Name = each.key
  
}
}