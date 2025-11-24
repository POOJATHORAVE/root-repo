variable "vpc_id" {
  description = "VPC ID for security groups"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}
