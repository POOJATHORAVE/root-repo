variable "instance_profile_arn" {
  description = "ARN of the IAM instance profile for Image Builder"
  type        = string
}

variable "instance_profile_name" {
  description = "Name of the IAM instance profile for Image Builder"
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

variable "rhel_8_base_image_arn" {
  description = "ARN of the base RHEL 8 image"
  type        = string
  default     = "arn:aws:imagebuilder:eu-west-1:aws:image/red-hat-enterprise-linux-8-x86/x.x.x"
}

variable "rhel_9_base_image_arn" {
  description = "ARN of the base RHEL 9 image"
  type        = string
  default     = "arn:aws:imagebuilder:eu-west-1:aws:image/red-hat-enterprise-linux-9-x86/x.x.x"
}

variable "cis_rhel_8_component_arn" {
  description = "ARN of the CIS RHEL 8 Level 1 component"
  type        = string
  default     = "arn:aws:imagebuilder:eu-west-1:aws:component/cis-rhel-8-level-1/x.x.x"
}

variable "cis_rhel_9_component_arn" {
  description = "ARN of the CIS RHEL 9 Level 1 component"
  type        = string
  default     = "arn:aws:imagebuilder:eu-west-1:aws:component/cis-rhel-9-level-1/x.x.x"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}
