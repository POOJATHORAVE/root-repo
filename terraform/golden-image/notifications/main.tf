# SNS Topic and Notifications for Image Builder Events

resource "aws_sns_topic" "image_notifications" {
  name         = "tesco-ims-golden-image-notifications"
  display_name = "Tesco IMS Golden Image Notifications"
  
  tags = merge(var.common_tags, {
    Name = "tesco-ims-golden-image-notifications"
  })
}

resource "aws_sns_topic_policy" "image_notifications" {
  arn = aws_sns_topic.image_notifications.arn
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.image_notifications.arn
      }
    ]
  })
}

# CloudWatch Event Rules for Image Builder notifications

# Image Creation Notification
resource "aws_cloudwatch_event_rule" "image_creation" {
  name        = "image-builder-creation"
  description = "Triggered when a new image is successfully created"
  
  event_pattern = jsonencode({
    source      = ["aws.imagebuilder"]
    detail-type = ["EC2 Image Builder Image State Change"]
    detail = {
      state = ["AVAILABLE"]
    }
  })
  
  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "image_creation" {
  rule      = aws_cloudwatch_event_rule.image_creation.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.image_notifications.arn
  
  input_transformer {
    input_paths = {
      imageArn = "$.detail.outputResources.amis[0].image"
      buildDate = "$.detail.buildDate"
      region = "$.detail.outputResources.amis[0].region"
    }
    input_template = "\"Image Created: <imageArn> in region <region> on <buildDate>\""
  }
}

# Image Deprecation Notification
resource "aws_cloudwatch_event_rule" "image_deprecation" {
  name        = "image-builder-deprecation"
  description = "Triggered when an image is marked as deprecated"
  
  event_pattern = jsonencode({
    source      = ["aws.imagebuilder"]
    detail-type = ["EC2 Image Builder Image State Change"]
    detail = {
      state = ["DEPRECATED"]
    }
  })
  
  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "image_deprecation" {
  rule      = aws_cloudwatch_event_rule.image_deprecation.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.image_notifications.arn
  
  input_transformer {
    input_paths = {
      imageArn = "$.detail.outputResources.amis[0].image"
    }
    input_template = "\"Image Deprecated: <imageArn>. Avoid using for new deployments.\""
  }
}

# Image Disable Notification
resource "aws_cloudwatch_event_rule" "image_disable" {
  name        = "image-builder-disable"
  description = "Triggered when an image is disabled"
  
  event_pattern = jsonencode({
    source      = ["aws.imagebuilder"]
    detail-type = ["EC2 Image Builder Image State Change"]
    detail = {
      state = ["DISABLED"]
    }
  })
  
  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "image_disable" {
  rule      = aws_cloudwatch_event_rule.image_disable.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.image_notifications.arn
  
  input_transformer {
    input_paths = {
      imageArn = "$.detail.outputResources.amis[0].image"
    }
    input_template = "\"Image Disabled: <imageArn>. No longer available for use.\""
  }
}

# Pipeline Execution Failure
resource "aws_cloudwatch_event_rule" "pipeline_failure" {
  name        = "image-builder-pipeline-failure"
  description = "Triggered when an image pipeline execution fails"
  
  event_pattern = jsonencode({
    source      = ["aws.imagebuilder"]
    detail-type = ["EC2 Image Builder Image State Change"]
    detail = {
      state = ["FAILED"]
    }
  })
  
  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "pipeline_failure" {
  rule      = aws_cloudwatch_event_rule.pipeline_failure.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.image_notifications.arn
  
  input_transformer {
    input_paths = {
      pipelineArn = "$.detail.pipelineArn"
      reason = "$.detail.statusMessage"
    }
    input_template = "\"Pipeline Failed: <pipelineArn>. Reason: <reason>\""
  }
}

# Pre-Deletion Warning (using custom scheduled CloudWatch Event)
resource "aws_cloudwatch_event_rule" "pre_deletion_warning" {
  name        = "image-builder-pre-deletion-warning"
  description = "Weekly check for images approaching deletion"
  
  schedule_expression = "cron(0 9 ? * MON *)"  # Every Monday at 9 AM
  
  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "pre_deletion_warning" {
  rule      = aws_cloudwatch_event_rule.pre_deletion_warning.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.image_notifications.arn
  
  input_transformer {
    input_template = "\"Weekly Reminder: Review images older than 35 days. They will be deleted at 42 days.\""
  }
}
