# Terrascan Integration with Jenkins

This repository demonstrates the integration of Terrascan (Infrastructure as Code security scanner) with Jenkins CI/CD pipeline.

## 📋 Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [File Structure](#file-structure)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Jenkins Pipeline](#jenkins-pipeline)
- [Local Testing](#local-testing)
- [Troubleshooting](#troubleshooting)

## 🔍 Overview

Terrascan is a static code analyzer for Infrastructure as Code (IaC) that helps detect compliance and security violations across various IaC tools including:
- Terraform
- Kubernetes
- Helm
- Docker
- AWS CloudFormation
- Azure Resource Manager (ARM)

This integration adds Terrascan scanning to your Jenkins pipeline to automatically check for security issues in your IaC code.

## ✅ Prerequisites

### Required Software
- Jenkins (version 2.x or higher)
- Git
- Bash shell
- Internet access (for downloading Terrascan)

### Jenkins Plugins (Recommended)
- Pipeline Plugin
- Git Plugin
- Workspace Cleanup Plugin

## 📁 File Structure

```
root-repo/
├── Jenkinsfile                    # Main Jenkins pipeline configuration
├── terrascan-config.toml          # Terrascan configuration file
├── scripts/
│   ├── run_gitleaks.sh           # Gitleaks scanning script
│   └── run_terrascan.sh          # Terrascan scanning script
├── terraform/                     # Sample Terraform files for testing
│   └── main.tf
└── README.md                      # This file
```

## 🚀 Installation

### Local Machine Installation

If you haven't installed Terrascan on your local machine yet:

#### Linux
```bash
# Download and install Terrascan
curl -L "https://github.com/tenable/terrascan/releases/download/v1.18.11/terrascan_1.18.11_Linux_x86_64.tar.gz" -o terrascan.tar.gz
tar -xf terrascan.tar.gz terrascan
chmod +x terrascan
sudo mv terrascan /usr/local/bin/
```

#### macOS
```bash
brew install terrascan
```

#### Windows
```powershell
# Download from GitHub releases
# https://github.com/tenable/terrascan/releases
# Extract and add to PATH
```

### Jenkins Agent Installation

The Jenkinsfile automatically installs Terrascan during the pipeline execution, but you can pre-install it on Jenkins agents:

```bash
# On Jenkins agent
curl -L "https://github.com/tenable/terrascan/releases/download/v1.18.11/terrascan_1.18.11_Linux_x86_64.tar.gz" -o terrascan.tar.gz
tar -xf terrascan.tar.gz terrascan
chmod +x terrascan
sudo mv terrascan /usr/local/bin/
```

## ⚙️ Configuration

### Terrascan Configuration File

The `terrascan-config.toml` file contains configuration options:

```toml
[scan]
  severity = "medium"          # Minimum severity level: low, medium, high
  skip-rules = []              # Rules to skip (comma-separated)
  categories = [               # Categories to scan
    "Identity and Access Management",
    "Data Protection",
    "Infrastructure Security",
    "Logging and Monitoring",
    "Resilience",
    "Compliance Validation"
  ]

[output]
  format = "json"              # Output format: json, yaml, xml, junit-xml, sarif
```

### Customizing Scan Rules

To skip specific rules, add them to `skip-rules`:

```toml
[scan]
  skip-rules = ["AWS.S3Bucket.DS.High.1041", "AWS.EC2.NS.High.0580"]
```

To scan specific policy types only:

```toml
[scan-rules]
  policy-type = ["aws", "kubernetes"]
```

## 📖 Usage

### Jenkins Pipeline

The integration includes three main stages:

1. **Checkout**: Clones the repository
2. **Secret Scan**: Runs Gitleaks for secret detection
3. **Terrascan Security Scan**: Runs Terrascan for IaC security scanning
4. **Build**: Conditional build based on target branch

The pipeline will:
- Automatically install Terrascan if not present
- Run security scans on all IaC files
- Fail if security violations are found
- Archive scan reports for review

### Running in Jenkins

1. Create a new Jenkins Pipeline job
2. Point it to this repository
3. Select "Pipeline script from SCM"
4. Set the Script Path to `Jenkinsfile`
5. Save and run the pipeline

## 🧪 Local Testing

### Test Terrascan Locally

```bash
# Navigate to repository root
cd /path/to/root-repo

# Make the script executable
chmod +x scripts/run_terrascan.sh

# Run Terrascan scan
./scripts/run_terrascan.sh . terrascan-config.toml human

# Or scan specific directory
./scripts/run_terrascan.sh ./terraform terrascan-config.toml json
```

### Test with Sample Terraform Files

```bash
# Scan the sample Terraform configuration
cd terraform
terrascan scan -i terraform -d . --verbose
```

### Generate Different Output Formats

```bash
# JSON format
./scripts/run_terrascan.sh . terrascan-config.toml json

# YAML format
./scripts/run_terrascan.sh . terrascan-config.toml yaml

# SARIF format (for GitHub integration)
./scripts/run_terrascan.sh . terrascan-config.toml sarif

# JUnit XML format (for Jenkins integration)
./scripts/run_terrascan.sh . terrascan-config.toml junit-xml
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Terrascan Not Found
```
Error: Terrascan is not installed or not in PATH
```
**Solution**: Install Terrascan following the installation instructions above.

#### 2. Permission Denied
```
Permission denied: ./scripts/run_terrascan.sh
```
**Solution**: Make the script executable:
```bash
chmod +x scripts/run_terrascan.sh
```

#### 3. No IaC Files Detected
```
No IaC files found
```
**Solution**: Ensure you have Terraform, Kubernetes, or other IaC files in your repository.

#### 4. Jenkins Pipeline Fails
- Check Jenkins console output for detailed error messages
- Verify Jenkins agent has internet access to download Terrascan
- Ensure the Jenkins user has execute permissions

### Debug Mode

Run Terrascan in verbose mode for detailed output:

```bash
terrascan scan --iac-type all --verbose --output human
```

## 📊 Understanding Scan Results

Terrascan reports violations with:
- **Severity**: HIGH, MEDIUM, LOW
- **Category**: Data Protection, Access Management, etc.
- **Rule ID**: Unique identifier for each rule
- **Description**: What the issue is
- **Remediation**: How to fix it

Example output:
```
Violation Details -
    
	Description    :  Ensure S3 bucket has versioning enabled
	File           :  terraform/main.tf
	Line           :  25
	Severity       :  MEDIUM
	Rule Name      :  s3BucketVersioning
	Rule ID        :  AWS.S3Bucket.IAM.Medium.0589
	Category       :  Data Protection
```

## 🔗 Additional Resources

- [Terrascan Official Documentation](https://runterrascan.io/)
- [Terrascan GitHub Repository](https://github.com/tenable/terrascan)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)

## 📝 Notes

- The pipeline will fail if any HIGH or MEDIUM severity violations are found
- Scan reports are automatically archived in Jenkins for review
- You can customize severity thresholds in `terrascan-config.toml`
- Terrascan is automatically downloaded and installed during the first pipeline run

## 🤝 Contributing

To contribute to this integration:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Submit a pull request

## 📄 License

This project configuration is provided as-is for demonstration purposes.
