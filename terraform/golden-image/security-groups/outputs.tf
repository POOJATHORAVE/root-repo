output "golden_image_sg_id" {
  description = "Security group ID for golden image instances"
  value       = aws_security_group.golden_image.id
}

output "vpc_endpoints_sg_id" {
  description = "Security group ID for VPC endpoints"
  value       = aws_security_group.vpc_endpoints.id
}
