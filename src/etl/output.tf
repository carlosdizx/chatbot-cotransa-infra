output "s3_bucket_name" {
  value = aws_s3_bucket.main_bucket.bucket
}

output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.cotransa_cloudfront.domain_name}"
}

output "cloudfront_url_csv" {
  value = "https://${aws_cloudfront_distribution.cotransa_cloudfront.domain_name}/normative_embeddings_cache.csv"
}
