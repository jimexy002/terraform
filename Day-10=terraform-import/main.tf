
data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "ec2" {
  ami           = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type = "t3.micro"

  tags = {
    Name = "ec2"
  }
}
# terraform import aws_s3_bucket.name sahuuuuuuuuu
resource "aws_s3_bucket" "name" {
}


resource "aws_s3_bucket_versioning" "name" {
  bucket = aws_s3_bucket.name.id
  versioning_configuration {
    status = "Suspended"
  }
}
