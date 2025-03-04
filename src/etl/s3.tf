resource "aws_s3_bucket" "main_bucket" {
  bucket = "cotransa-bucket-${random_uuid.uuid.result}"
}

resource "aws_s3_bucket_ownership_controls" "private_access" {
  bucket = aws_s3_bucket.main_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "private_access_block" {
  bucket                  = aws_s3_bucket.main_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "cotransa-oac"
  description                       = "CloudFront OAC for private S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_policy" "private_access_policy" {
  bucket = aws_s3_bucket.main_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.main_bucket.id}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cotransa_cloudfront.arn
          }
        }
      }
    ]
  })
}
