output "instance_role_arn" {
  description = "ARN of the Image Builder IAM role"
  value       = aws_iam_role.image_builder.arn
}

output "instance_profile_arn" {
  description = "ARN of the Image Builder instance profile"
  value       = aws_iam_instance_profile.image_builder.arn
}

output "lifecycle_role_arn" {
  description = "ARN of the lifecycle management IAM role"
  value       = aws_iam_role.lifecycle.arn
}
