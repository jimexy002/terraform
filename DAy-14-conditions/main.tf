variable "babu" {
  type = bool
  default = false
}



resource "aws_instance" "name" {
  ami = "ami-0521cb2d60cfbb1a6"
  instance_type = "t3.micro"
  count = var.babu ? 1:0
}

#     #if babu is true then create 1 instance if false then create 0 instance

#     #true 1
#     #false 0
    

  
#}

########### second condition #############

variable "aws_region" {
  description = "The region in which to create the infrastructure"
  type        = string
  nullable    = false
  default     = "us-east-1" #here we need to define either us-west-1 or eu-west-2 if i give other region will get error 
  validation {
    condition = var.aws_region == "us-east-1" || var.aws_region == "ap-south-1"
    error_message = "The variable 'aws_region' must be one of the following regions: us-east-1, ap-south-1"
  }
}



provider "aws" {
  region = var.aws_region
  
   
  }

 resource "aws_s3_bucket" "dev" {
    bucket = "statefile-configuresssdsfsff"
    
    
  
}

#Example-3
# variable "environment" {
#   type    = string
#   default = "test"
# }

# resource "aws_instance" "example" {
#   count         = var.environment == "prod" ? 3 : 1
#   ami           = "ami-02dfbd4ff395f2a1b"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "example-${count.index}"
#   }
# }

# #In this case:
# #If var.environment == "prod" â count = 3
# #Else (like dev, qa, etc.) â count = 1
# #terraform apply -var="environment=dev"