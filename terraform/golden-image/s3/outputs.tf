output "binaries_bucket_name" {
  description = "Name of the binaries S3 bucket"
  value       = aws_s3_bucket.binaries.id
}

output "binaries_bucket_arn" {
  description = "ARN of the binaries S3 bucket"
  value       = aws_s3_bucket.binaries.arn
}

output "image_scan_bucket_name" {
  description = "Name of the image scan S3 bucket"
  value       = aws_s3_bucket.image_scan.id
}

output "image_scan_bucket_arn" {
  description = "ARN of the image scan S3 bucket"
  value       = aws_s3_bucket.image_scan.arn
}
