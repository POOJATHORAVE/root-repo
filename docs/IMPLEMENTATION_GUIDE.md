# Golden/Bakery RHEL Image - Implementation Guide

## Table of Contents
1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [Step-by-Step Deployment](#step-by-step-deployment)
3. [Post-Deployment Verification](#post-deployment-verification)
4. [Operational Procedures](#operational-procedures)
5. [Troubleshooting](#troubleshooting)

## Pre-Deployment Checklist

### AWS Prerequisites
- [ ] AWS Account with Administrator access to Shared Services account
- [ ] VPC with private subnets configured
- [ ] VPC endpoints for SSM, EC2, S3, and CloudWatch
- [ ] KMS key for AMI encryption (optional, uses default if not specified)
- [ ] Network connectivity to required repositories and services

### Software Binaries
- [ ] Qualys Cloud Agent RPM downloaded
- [ ] Datadog API key obtained
- [ ] Defender for Endpoint configuration details
- [ ] Azure Arc connection information

### Terraform Setup
- [ ] Terraform 1.0+ installed
- [ ] AWS CLI configured with appropriate credentials
- [ ] Git repository cloned locally

## Step-by-Step Deployment

### Step 1: Prepare Configuration

1. Navigate to the terraform directory:
```bash
cd terraform/golden-image
```

2. Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

3. Edit terraform.tfvars with your environment values

### Step 2: Initialize and Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Additional Resources

- AWS Image Builder Documentation: https://docs.aws.amazon.com/imagebuilder/
- CIS Benchmarks: https://www.cisecurity.org/cis-benchmarks
