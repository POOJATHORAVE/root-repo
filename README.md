# AWS Golden/Bakery RHEL Image Infrastructure

This repository contains the Infrastructure as Code (IaC) implementation for AWS EC2 Image Builder to create secure, standardized "Golden/Base" images for RHEL (Red Hat Enterprise Linux) 8.10 and 9.6.

## Overview

The solution provisions a secure image building pipeline in AWS using Terraform, implementing:

- **CIS Level 1 Hardened Images**: RHEL 8.10 and 9.6 with CIS benchmarks
- **Pre-installed Software Agents**: SSM Agent, Qualys Agent, Datadog Agent, CloudWatch Agent, AWS CLI v2
- **Azure Arc Integration**: Defender for Endpoint and AMA agent support
- **Automated Patching**: Weekly image builds with latest patches
- **Lifecycle Management**: Automated deprecation, disabling, and deletion of old images
- **Notification System**: SNS notifications for all image lifecycle events

## Architecture

### Key Components

1. **IAM Role** (`iam-ss-dplygicom`): Instance profile with necessary permissions
2. **S3 Buckets**: 
   - `ims-prod-s3-euw1-gibinaries`: Software binaries storage
   - `ims-prod-s3-euw1-imagescan`: Image scanning and validation
3. **Security Groups**:
   - `sg-ss-goldenimage`: For image building instances
   - `sg-ss-vpcendpoints`: For VPC endpoints
4. **Image Builder Components**:
   - Custom software installation component
   - CIS Level 1 benchmark baseline
   - RHEL 8.10 and 9.6 recipes
5. **Image Pipelines**: Weekly automated builds
6. **Lifecycle Policies**:
   - Deprecate after 2 weeks
   - Disable after 4 weeks
   - Delete after 6 weeks

## Directory Structure

```
terraform/
└── golden-image/
    ├── main.tf                 # Main configuration
    ├── variables.tf            # Input variables
    ├── outputs.tf              # Output values
    ├── iam/                    # IAM roles and policies
    ├── s3/                     # S3 bucket configurations
    ├── security-groups/        # Security group definitions
    ├── image-builder/          # Image Builder components, recipes, pipelines
    ├── lifecycle/              # Lifecycle policies
    └── notifications/          # SNS and CloudWatch Events
```

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0
- AWS CLI configured
- VPC with private subnets
- Access to CIS hardened base images

## Configuration

### Required Variables

Create a `terraform.tfvars` file in the `terraform/golden-image/` directory:

```hcl
aws_region          = "eu-west-1"
vpc_id              = "vpc-ss-prd-euw1-01"
private_subnet_id   = "subnet-xxxxx"
target_account_ids  = ["123456789012", "234567890123"]

common_tags = {
  CostCenter  = "IMS"
  Environment = "Production"
  Owner       = "Tesco-IMS"
  Project     = "Golden-Image"
  Application = "EC2-Image-Builder"
  Compliance  = "CIS-Level-1"
}
```

### Software Binaries

Before running the infrastructure, upload required software binaries to S3:

```bash
# Upload Qualys agent
aws s3 cp qualys-cloud-agent.x86_64.rpm s3://ims-prod-s3-euw1-gibinaries/qualys/
```

## Deployment

### Initialize Terraform

```bash
cd terraform/golden-image
terraform init
```

### Plan Infrastructure

```bash
terraform plan
```

### Apply Configuration

```bash
terraform apply
```

## Image Naming Convention

Images follow the naming convention:
```
Tesco-IMS-GoldenImage-<OS>-<Version>-<Date>-<Hash>
```

Example: `Tesco-IMS-GoldenImage-RHEL8.10-2025-06-17-45331960`

## Tagging Strategy

All resources are tagged with:

- **CostCenter**: For cost allocation
- **Environment**: Deployment environment (Production)
- **Owner**: Resource owner (Tesco-IMS)
- **Project**: Project identifier (Golden-Image)
- **Application**: Application name (EC2-Image-Builder)
- **Compliance**: Compliance requirement (CIS-Level-1)
- **OSVersion**: Operating system version (RHEL-8.10 or RHEL-9.6)
- **ReleaseDate**: Image release date

## Image Lifecycle

### Creation
1. Image Builder builds image weekly (every Monday)
2. Installs all software agents and security patches
3. Runs CIS Level 1 hardening
4. Performs automated tests
5. Distributes to target accounts

### Maintenance
1. **Week 1-2**: Image is active and recommended
2. **Week 2**: Image is deprecated (still usable)
3. **Week 4**: Image is disabled (cannot launch new instances)
4. **Week 6**: Image and snapshots are deleted

### Notifications
SNS notifications are sent for:
- Image creation
- Image deprecation
- Image disable
- Pre-deletion warnings
- Pipeline failures

## Security Features

- **Encryption**: All AMIs and EBS volumes encrypted with AWS KMS
- **CIS Hardened**: Level 1 benchmark compliance
- **IMDSv2**: Enforced on all instances
- **No Default Security Groups**: Custom security groups only
- **Private Access**: No public AMI sharing
- **IAM Controls**: Restricted access to authorized users
- **CloudWatch Logging**: All build activities logged

## Testing Process

After image creation:
1. Launch test EC2 instance
2. Qualys agent reports to Tesco IMS tenant
3. Run vulnerability and compliance scans
4. Address any findings
5. Release image for production use

## Patching Schedule

Images are patched on the **3rd Monday of every month**:
- Automated weekly builds include latest patches
- Monthly review of security updates
- Emergency patches applied as needed

## Troubleshooting

### Pipeline Failures
Check CloudWatch logs:
```bash
aws logs tail /aws/imagebuilder/Tesco-IMS-GoldenImage-RHEL-8.10 --follow
```

### Image Build Issues
1. Verify IAM role permissions
2. Check security group rules
3. Ensure VPC endpoints are configured
4. Verify S3 bucket access

### Agent Installation Failures
1. Check S3 binaries bucket for required files
2. Verify network connectivity
3. Review component execution logs

## Support

For issues or questions:
- Review CloudWatch logs
- Check SNS notifications
- Contact: asif.ahmed@tescoims.com

## References

- AWS Design Document V1.2, Section 6.8 Golden/Base Image
- Epic IMSA-3695
- Sub-tasks: IMSA-3633, IMSA-3634, IMSA-3635, IMSA-3636
- CIS Benchmarks: https://www.cisecurity.org/

## License

Internal use only - Tesco Insurance & Money Services
