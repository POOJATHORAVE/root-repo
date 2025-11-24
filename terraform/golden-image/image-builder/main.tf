# Image Builder Components
# Component for installing custom software agents

resource "aws_imagebuilder_component" "linux_baseline" {
  name        = "IMSLinuxBaseline"
  platform    = "Linux"
  version     = "1.0.0"
  description = "Install Custom Software Agents: SSM Agent, Qualys Agent, Datadog Agent, AWS CLI-V2, CloudWatch Agent, Defender for Endpoint, Azure Arc, and Update Linux"
  
  data = yamlencode({
    schemaVersion = 1.0
    phases = [
      {
        name = "build"
        steps = [
          {
            name   = "InstallDependencies"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "echo 'Installing required dependencies...'",
                "sudo yum install -y jq unzip"
              ]
            }
          },
          {
            name   = "InstallSSMAgent"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "echo 'Installing SSM Agent...'",
                "sudo yum install -y amazon-ssm-agent",
                "sudo systemctl enable amazon-ssm-agent",
                "sudo systemctl start amazon-ssm-agent"
              ]
            }
          },
          {
            name   = "InstallQualysAgent"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "echo 'Downloading Qualys Agent from S3...'",
                "aws s3 cp s3://${var.s3_binaries_bucket}/qualys/qualys-cloud-agent.x86_64.rpm /tmp/",
                "sudo rpm -ivh /tmp/qualys-cloud-agent.x86_64.rpm",
                "echo 'Retrieving Qualys credentials from Secrets Manager...'",
                "QUALYS_SECRETS=$(aws secretsmanager get-secret-value --secret-id qualys-credentials --query SecretString --output text)",
                "ACTIVATION_ID=$(echo $QUALYS_SECRETS | jq -r '.activation_id')",
                "CUSTOMER_ID=$(echo $QUALYS_SECRETS | jq -r '.customer_id')",
                "sudo /usr/local/qualys/cloud-agent/bin/qualys-cloud-agent.sh ActivationId=$ACTIVATION_ID CustomerId=$CUSTOMER_ID",
                "rm -f /tmp/qualys-cloud-agent.x86_64.rpm"
              ]
            }
          },
          {
            name   = "InstallDatadogAgent"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "echo 'Installing Datadog Agent...'",
                "echo 'Retrieving Datadog API key from Secrets Manager...'",
                "DD_API_KEY=$(aws secretsmanager get-secret-value --secret-id datadog-api-key --query SecretString --output text | jq -r '.api_key')",
                "DD_AGENT_MAJOR_VERSION=7 DD_SITE='datadoghq.com' bash -c \"$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)\""
              ]
            }
          },
          {
            name   = "InstallAWSCLIv2"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "echo 'Installing AWS CLI v2...'",
                "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o /tmp/awscliv2.zip",
                "unzip /tmp/awscliv2.zip -d /tmp",
                "sudo /tmp/aws/install",
                "rm -rf /tmp/awscliv2.zip /tmp/aws"
              ]
            }
          },
          {
            name   = "InstallCloudWatchAgent"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "echo 'Installing CloudWatch Agent...'",
                "sudo yum install -y amazon-cloudwatch-agent",
                "sudo systemctl enable amazon-cloudwatch-agent"
              ]
            }
          },
          {
            name   = "PrepareAzureArcIntegration"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "echo 'Azure Arc agent will be auto-provisioned post-deployment'",
                "echo 'Defender for Endpoint will be deployed via Azure Arc'",
                "echo 'AMA agent will be pushed via Azure Arc for Sentinel logs'"
              ]
            }
          },
          {
            name   = "UpdateLinux"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "echo 'Updating Linux packages...'",
                "sudo yum update -y",
                "sudo yum clean all"
              ]
            }
          },
          {
            name   = "EnableIMDSv2"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "echo 'Configuring IMDSv2...'",
                "TOKEN=$(curl -X PUT 'http://169.254.169.254/latest/api/token' -H 'X-aws-ec2-metadata-token-ttl-seconds: 21600')",
                "echo 'IMDSv2 is enforced at the instance level'"
              ]
            }
          }
        ]
      },
      {
        name = "validate"
        steps = [
          {
            name   = "ValidateInstallations"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "echo 'Validating installed software...'",
                "aws --version",
                "systemctl status amazon-ssm-agent",
                "systemctl status amazon-cloudwatch-agent"
              ]
            }
          }
        ]
      }
    ]
  })
  
  tags = merge(var.common_tags, {
    Name = "IMSLinuxBaseline"
  })
}

# Image Recipes for RHEL 8.10 and 9.6
resource "aws_imagebuilder_image_recipe" "rhel_8_10" {
  name         = "Tesco-IMS-GoldenImage-RHEL-8.10-Recipe"
  version      = "1.0.0"
  parent_image = var.rhel_8_base_image_arn
  description  = "Tesco IMS Golden Image for RHEL 8.10 with CIS Level 1 Benchmark"
  
  component {
    component_arn = var.cis_rhel_8_component_arn
  }
  
  component {
    component_arn = aws_imagebuilder_component.linux_baseline.arn
  }
  
  block_device_mapping {
    device_name = "/dev/sda1"
    
    ebs {
      delete_on_termination = true
      volume_size           = 50
      volume_type           = "gp3"
      encrypted             = true
    }
  }
  
  tags = merge(var.common_tags, {
    Name      = "GoldenImage-RHEL-8.10"
    OSVersion = "RHEL-8.10"
  })
}

resource "aws_imagebuilder_image_recipe" "rhel_9_6" {
  name         = "Tesco-IMS-GoldenImage-RHEL-9.6-Recipe"
  version      = "1.0.0"
  parent_image = var.rhel_9_base_image_arn
  description  = "Tesco IMS Golden Image for RHEL 9.6 with CIS Level 1 Benchmark"
  
  component {
    component_arn = var.cis_rhel_9_component_arn
  }
  
  component {
    component_arn = aws_imagebuilder_component.linux_baseline.arn
  }
  
  block_device_mapping {
    device_name = "/dev/sda1"
    
    ebs {
      delete_on_termination = true
      volume_size           = 50
      volume_type           = "gp3"
      encrypted             = true
    }
  }
  
  tags = merge(var.common_tags, {
    Name      = "GoldenImage-RHEL-9.6"
    OSVersion = "RHEL-9.6"
  })
}

# Infrastructure Configuration
resource "aws_imagebuilder_infrastructure_configuration" "main" {
  name                          = "Tesco-IMS-GoldenImage-Infrastructure-Config"
  instance_profile_name         = split("/", var.instance_profile_arn)[1]
  subnet_id                     = var.subnet_id
  security_group_ids            = [var.security_group_id]
  instance_types                = ["t3.medium"]
  terminate_instance_on_failure = true
  
  logging {
    s3_logs {
      s3_bucket_name = var.s3_binaries_bucket
      s3_key_prefix  = "image-builder-logs"
    }
  }
  
  tags = var.common_tags
}

# Distribution Configuration
resource "aws_imagebuilder_distribution_configuration" "main" {
  name        = "Tesco-IMS-GoldenImage-Distribution-Config-RHEL"
  description = "Distribution configuration for Tesco RHEL Golden Images"
  
  distribution {
    region = "eu-west-1"
    
    ami_distribution_configuration {
      name = "Tesco-IMS-GoldenImage-{{ imagebuilder:buildDate }}"
      
      ami_tags = merge(var.common_tags, {
        Name        = "Tesco-IMS-GoldenImage"
        ImageType   = "GoldenImage"
        ReleaseDate = "{{ imagebuilder:buildDate }}"
      })
      
      launch_permission {
        user_ids = var.target_account_ids
      }
    }
  }
  
  tags = var.common_tags
}

# Image Pipeline for RHEL 8.10
resource "aws_imagebuilder_image_pipeline" "rhel_8_10" {
  name                             = "Tesco-IMS-GoldenImage-RHEL-8.10"
  description                      = "Pipeline for building Tesco IMS RHEL 8.10 Golden Images"
  image_recipe_arn                 = aws_imagebuilder_image_recipe.rhel_8_10.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.main.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.main.arn
  status                           = "ENABLED"
  
  schedule {
    schedule_expression = "cron(0 0 ? * MON *)"  # Weekly on Monday
  }
  
  image_tests_configuration {
    image_tests_enabled = true
    timeout_minutes     = 60
  }
  
  tags = merge(var.common_tags, {
    Name      = "Tesco-IMS-GoldenImage-RHEL-8.10"
    OSVersion = "RHEL-8.10"
  })
}

# Image Pipeline for RHEL 9.6
resource "aws_imagebuilder_image_pipeline" "rhel_9_6" {
  name                             = "Tesco-IMS-GoldenImage-RHEL-9.6"
  description                      = "Pipeline for building Tesco IMS RHEL 9.6 Golden Images"
  image_recipe_arn                 = aws_imagebuilder_image_recipe.rhel_9_6.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.main.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.main.arn
  status                           = "ENABLED"
  
  schedule {
    schedule_expression = "cron(0 0 ? * MON *)"  # Weekly on Monday
  }
  
  image_tests_configuration {
    image_tests_enabled = true
    timeout_minutes     = 60
  }
  
  tags = merge(var.common_tags, {
    Name      = "Tesco-IMS-GoldenImage-RHEL-9.6"
    OSVersion = "RHEL-9.6"
  })
}
