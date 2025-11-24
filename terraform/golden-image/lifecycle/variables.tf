variable "iam_role_arn" {
  description = "ARN of the IAM role for lifecycle management"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}
