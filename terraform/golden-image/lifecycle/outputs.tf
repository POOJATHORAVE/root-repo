output "lifecycle_policy_arn" {
  description = "ARN of the image lifecycle policy"
  value       = aws_imagebuilder_lifecycle_policy.ami_lifecycle.arn
}
