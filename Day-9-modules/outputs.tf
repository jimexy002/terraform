output "public_bucket_name" {
  value = aws_s3_bucket.public_bucket.bucket
}

output "public_bucket_arn" {
  value = aws_s3_bucket.public_bucket.arn
}
