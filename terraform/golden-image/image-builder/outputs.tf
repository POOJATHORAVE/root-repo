output "linux_baseline_component_arn" {
  description = "ARN of the Linux Baseline component"
  value       = aws_imagebuilder_component.linux_baseline.arn
}

output "rhel_8_10_recipe_arn" {
  description = "ARN of RHEL 8.10 image recipe"
  value       = aws_imagebuilder_image_recipe.rhel_8_10.arn
}

output "rhel_9_6_recipe_arn" {
  description = "ARN of RHEL 9.6 image recipe"
  value       = aws_imagebuilder_image_recipe.rhel_9_6.arn
}

output "infrastructure_config_arn" {
  description = "ARN of infrastructure configuration"
  value       = aws_imagebuilder_infrastructure_configuration.main.arn
}

output "distribution_config_arn" {
  description = "ARN of distribution configuration"
  value       = aws_imagebuilder_distribution_configuration.main.arn
}

output "rhel_8_10_pipeline_arn" {
  description = "ARN of RHEL 8.10 image pipeline"
  value       = aws_imagebuilder_image_pipeline.rhel_8_10.arn
}

output "rhel_9_6_pipeline_arn" {
  description = "ARN of RHEL 9.6 image pipeline"
  value       = aws_imagebuilder_image_pipeline.rhel_9_6.arn
}
