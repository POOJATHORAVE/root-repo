# S3 Buckets for Image Builder
# 1. ims-prod-s3-euw1-gibinaries - for software binaries (Qualys agent, etc.)
# 2. ims-prod-s3-euw1-imagescan - for CIS benchmark image scanning

resource "aws_s3_bucket" "binaries" {
  bucket = "ims-prod-s3-euw1-gibinaries"
  
  tags = merge(var.common_tags, {
    Name        = "ims-prod-s3-euw1-gibinaries"
    Description = "S3 bucket to store binaries of Qualys agent and other software"
  })
}

resource "aws_s3_bucket_public_access_block" "binaries" {
  bucket = aws_s3_bucket.binaries.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "binaries" {
  bucket = aws_s3_bucket.binaries.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "binaries" {
  bucket = aws_s3_bucket.binaries.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Image Scan Bucket
resource "aws_s3_bucket" "image_scan" {
  bucket = "ims-prod-s3-euw1-imagescan"
  
  tags = merge(var.common_tags, {
    Name        = "ims-prod-s3-euw1-imagescan"
    Description = "S3 bucket for integrity test of CIS Benchmark Images"
  })
}

resource "aws_s3_bucket_public_access_block" "image_scan" {
  bucket = aws_s3_bucket.image_scan.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "image_scan" {
  bucket = aws_s3_bucket.image_scan.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "image_scan" {
  bucket = aws_s3_bucket.image_scan.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bucket policy for Image Builder access to binaries bucket
resource "aws_s3_bucket_policy" "binaries" {
  bucket = aws_s3_bucket.binaries.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowImageBuilderAccess"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.binaries.arn,
          "${aws_s3_bucket.binaries.arn}/*"
        ]
      }
    ]
  })
}
