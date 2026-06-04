
terraform {
  backend "s3" {
    bucket = "sahuuuuuuuuu"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}