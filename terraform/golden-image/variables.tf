# Variables for Golden/Bakery RHEL Image Infrastructure

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_id" {
  description = "VPC ID for security groups (vpc-ss-prd-euw1-01)"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID for Image Builder infrastructure"
  type        = string
}

variable "target_account_ids" {
  description = "List of AWS account IDs to share the golden images with"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    CostCenter  = "IMS"
    Environment = "Production"
    Owner       = "Tesco-IMS"
    Project     = "Golden-Image"
    Application = "EC2-Image-Builder"
    Compliance  = "CIS-Level-1"
  }
}
