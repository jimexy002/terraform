variable "ami_id" {
  description = "The AMI id for the ec2 instance"
  type = string
default = ""
}

variable "instance_type" {
  description = "The instance type for the ec2 instance"
  type = string
  default = ""
}

variable "name" {
  description = "The name for the ec2 instance"
  type =string
  default = ""
}