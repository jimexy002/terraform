resource "aws_instance" "insta" {
    ami =      "ami-0e564a15089b1ff77"
instance_type = "t3.micro"
tags = {
    name = "nit"
}
# lifecycle {
#   create_before_destroy = true
# }
# lifecycle {
#   ignore_changes = [ tags, ]
# }
lifecycle {
  prevent_destroy = true
}
}