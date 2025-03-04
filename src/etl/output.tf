output "s3_bucket_name" {
  value = aws_s3_bucket.public_bucket.bucket
}

output "s3_bucket_url" {
  value = "https://${aws_s3_bucket.public_bucket.bucket}.s3.amazonaws.com"
}