# Security Groups for Image Builder
# 1. sg-ss-goldenimage - for golden image instances
# 2. sg-ss-vpcendpoints - for VPC endpoints

resource "aws_security_group" "golden_image" {
  name        = "sg-ss-goldenimage"
  description = "Security group for golden image building instances"
  vpc_id      = var.vpc_id
  
  # Egress rules - Allow all outbound traffic for software downloads
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS for software downloads and AWS API calls"
  }
  
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP for package repositories"
  }
  
  tags = merge(var.common_tags, {
    Name = "sg-ss-goldenimage"
  })
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "sg-ss-vpcendpoints"
  description = "Security group for VPC endpoints used by Image Builder"
  vpc_id      = var.vpc_id
  
  # Ingress rule - Allow traffic from golden image security group
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.golden_image.id]
    description     = "Allow HTTPS from golden image instances"
  }
  
  tags = merge(var.common_tags, {
    Name = "sg-ss-vpcendpoints"
  })
}

# Add egress rule to allow access to VPC endpoints
resource "aws_security_group_rule" "golden_image_to_vpc_endpoints" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.vpc_endpoints.id
  security_group_id        = aws_security_group.golden_image.id
  description              = "Allow access to VPC endpoints"
}
