# Image Lifecycle Policy
# Automates deprecation, disabling, and deletion of AMIs

resource "aws_imagebuilder_lifecycle_policy" "ami_lifecycle" {
  name        = "AMI-LifeCycle-Policy"
  description = "Defines the process of deprecating, disabling and deleting AMIs"
  
  resource_type = "AMI_IMAGE"
  status        = "ENABLED"
  execution_role = var.iam_role_arn
  
  # Policy Details
  policy_detail {
    action {
      type = "DEPRECATE"
      include_resources {
        amis = true
      }
    }
    filter {
      type  = "AGE"
      value = var.deprecate_after_days
      unit  = "DAYS"
    }
  }
  
  policy_detail {
    action {
      type = "DISABLE"
      include_resources {
        amis = true
      }
    }
    filter {
      type  = "AGE"
      value = var.disable_after_days
      unit  = "DAYS"
    }
  }
  
  policy_detail {
    action {
      type = "DELETE"
      include_resources {
        amis      = true
        snapshots = true
      }
    }
    filter {
      type  = "AGE"
      value = var.delete_after_days
      unit  = "DAYS"
    }
    # Exclusion rules
    exclusion_rules {
      amis {
        is_public              = false
        regions                = ["eu-west-1"]
        tag_map = {
          "Retain" = "true"
        }
      }
    }
  }
  
  # Resource selection
  resource_selection {
    recipes {
      name    = "Tesco-IMS-GoldenImage-RHEL-8.10-Recipe"
      semantic_version = "1.0.0"
    }
    recipes {
      name    = "Tesco-IMS-GoldenImage-RHEL-9.6-Recipe"
      semantic_version = "1.0.0"
    }
  }
  
  tags = merge(var.common_tags, {
    Name = "AMI-LifeCycle-Policy"
  })
}
