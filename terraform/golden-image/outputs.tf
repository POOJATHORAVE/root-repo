# Outputs for Golden/Bakery RHEL Image Infrastructure

output "iam_role_arn" {
  description = "ARN of the IAM role for Image Builder"
  value       = module.iam.instance_role_arn
}

output "instance_profile_arn" {
  description = "ARN of the instance profile for Image Builder"
  value       = module.iam.instance_profile_arn
}

output "binaries_bucket_name" {
  description = "Name of S3 bucket for software binaries"
  value       = module.s3.binaries_bucket_name
}

output "image_scan_bucket_name" {
  description = "Name of S3 bucket for image scanning"
  value       = module.s3.image_scan_bucket_name
}

output "golden_image_sg_id" {
  description = "Security group ID for golden image instances"
  value       = module.security_groups.golden_image_sg_id
}

output "vpc_endpoints_sg_id" {
  description = "Security group ID for VPC endpoints"
  value       = module.security_groups.vpc_endpoints_sg_id
}

output "rhel_8_10_pipeline_arn" {
  description = "ARN of RHEL 8.10 image pipeline"
  value       = module.image_builder.rhel_8_10_pipeline_arn
}

output "rhel_9_6_pipeline_arn" {
  description = "ARN of RHEL 9.6 image pipeline"
  value       = module.image_builder.rhel_9_6_pipeline_arn
}

output "sns_topic_arn" {
  description = "ARN of SNS topic for image notifications"
  value       = module.notifications.sns_topic_arn
}
