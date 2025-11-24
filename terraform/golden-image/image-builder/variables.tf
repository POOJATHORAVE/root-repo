variable "instance_profile_arn" {
  description = "ARN of the IAM instance profile for Image Builder"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for Image Builder infrastructure"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for Image Builder instances"
  type        = string
}

variable "s3_binaries_bucket" {
  description = "S3 bucket name for software binaries"
  type        = string
}

variable "target_account_ids" {
  description = "List of AWS account IDs to share images with"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}
