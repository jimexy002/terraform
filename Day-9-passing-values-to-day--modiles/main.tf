module "bab" {
  source        = "../Day-9-modules"
  instance_type = "t3.micro"
  name          = "babu"
  ami_id        = "ami-0db56f446d44f2f09"
  bucket_name   = "babu-public-demo-bucket-20260611"
}
