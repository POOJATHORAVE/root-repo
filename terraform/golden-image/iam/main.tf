# IAM Role and Policies for Image Builder
# Role Name: iam-ss-dplygicom

resource "aws_iam_role" "image_builder" {
  name               = "iam-ss-dplygicom"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  tags = merge(var.common_tags, {
    Name = "iam-ss-dplygicom"
  })
}

# Custom S3 Policy for Image Builder
resource "aws_iam_policy" "s3_access" {
  name        = "ImageBuilderS3AccessPolicy"
  description = "Policy for Image Builder to access specific S3 buckets"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::ims-prod-s3-euw1-gibinaries",
          "arn:aws:s3:::ims-prod-s3-euw1-gibinaries/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::ims-prod-s3-euw1-imagescan",
          "arn:aws:s3:::ims-prod-s3-euw1-imagescan/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::*/image-builder-logs/*"
        ]
      }
    ]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.image_builder.name
  policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  role       = aws_iam_role.image_builder.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "image_builder_profile" {
  role       = aws_iam_role.image_builder.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
}

resource "aws_iam_role_policy_attachment" "ecr_container_builds" {
  role       = aws_iam_role.image_builder.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
}

# Custom policy for Image Builder Lifecycle
resource "aws_iam_policy" "lifecycle_execution" {
  name        = "EC2ImageBuilderLifecycleExecutionPolicy"
  description = "Policy for EC2 Image Builder Lifecycle management"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "imagebuilder:GetImage",
          "imagebuilder:GetImagePipeline",
          "imagebuilder:ListImages",
          "imagebuilder:GetImageRecipe",
          "ec2:DescribeImages",
          "ec2:DeregisterImage",
          "ec2:DeleteSnapshot",
          "ec2:ModifyImageAttribute",
          "ec2:DescribeSnapshots"
        ]
        Resource = "*"
      }
    ]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "lifecycle_execution" {
  role       = aws_iam_role.image_builder.name
  policy_arn = aws_iam_policy.lifecycle_execution.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "image_builder" {
  name = "iam-ss-dplygicom-profile"
  role = aws_iam_role.image_builder.name
  
  tags = var.common_tags
}

# IAM Role for Lifecycle Policies
resource "aws_iam_role" "lifecycle" {
  name               = "iam-ss-imagebuilder-lifecycle"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "imagebuilder.amazonaws.com"
        }
      }
    ]
  })
  
  tags = merge(var.common_tags, {
    Name = "iam-ss-imagebuilder-lifecycle"
  })
}

resource "aws_iam_role_policy_attachment" "lifecycle_role" {
  role       = aws_iam_role.lifecycle.name
  policy_arn = aws_iam_policy.lifecycle_execution.arn
}

# Additional policy for CloudWatch Logs
resource "aws_iam_policy" "cloudwatch_logs" {
  name        = "ImageBuilderCloudWatchLogsPolicy"
  description = "Policy for Image Builder to write to CloudWatch Logs"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/aws/imagebuilder/*"
      }
    ]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.image_builder.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}

# Policy for accessing Secrets Manager
resource "aws_iam_policy" "secrets_manager" {
  name        = "ImageBuilderSecretsManagerPolicy"
  description = "Policy for Image Builder to access secrets in Secrets Manager"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:qualys-credentials-*",
          "arn:aws:secretsmanager:*:*:secret:datadog-api-key-*"
        ]
      }
    ]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "secrets_manager" {
  role       = aws_iam_role.image_builder.name
  policy_arn = aws_iam_policy.secrets_manager.arn
}
