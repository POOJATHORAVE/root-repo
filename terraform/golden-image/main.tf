# Main Terraform configuration for AWS Golden/Bakery RHEL Images
# This configuration creates a secure "Golden/Base Image" in AWS using EC2 Image Builder

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = var.common_tags
  }
}

# IAM Role and Policies
module "iam" {
  source = "./iam"
  
  common_tags = var.common_tags
}

# S3 Buckets
module "s3" {
  source = "./s3"
  
  image_builder_role_arn = module.iam.instance_role_arn
  common_tags            = var.common_tags
  
  depends_on = [module.iam]
}

# Security Groups
module "security_groups" {
  source = "./security-groups"
  
  vpc_id      = var.vpc_id
  common_tags = var.common_tags
}

# Image Builder Components, Recipes, and Pipelines
module "image_builder" {
  source = "./image-builder"
  
  instance_profile_arn = module.iam.instance_profile_arn
  subnet_id            = var.private_subnet_id
  security_group_id    = module.security_groups.golden_image_sg_id
  s3_binaries_bucket   = module.s3.binaries_bucket_name
  target_account_ids   = var.target_account_ids
  common_tags          = var.common_tags
  
  depends_on = [module.iam, module.s3, module.security_groups]
}

# Image Lifecycle Policies
module "lifecycle" {
  source = "./lifecycle"
  
  iam_role_arn = module.iam.lifecycle_role_arn
  common_tags  = var.common_tags
  
  depends_on = [module.image_builder]
}

# Notifications
module "notifications" {
  source = "./notifications"
  
  common_tags = var.common_tags
  
  depends_on = [module.image_builder]
}
