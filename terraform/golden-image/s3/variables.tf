variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

variable "image_builder_role_arn" {
  description = "ARN of the IAM role used by Image Builder"
  type        = string
  default     = ""
}
