variable "iam_role_arn" {
  description = "ARN of the IAM role for lifecycle management"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

variable "deprecate_after_days" {
  description = "Number of days after which to deprecate images"
  type        = number
  default     = 14
}

variable "disable_after_days" {
  description = "Number of days after which to disable images"
  type        = number
  default     = 28
}

variable "delete_after_days" {
  description = "Number of days after which to delete images"
  type        = number
  default     = 42
}
