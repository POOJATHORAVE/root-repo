# Terrascan Quick Reference Guide

## Installation Commands

### Linux (Ubuntu/Debian)
```bash
# Download latest version
curl -L "https://github.com/tenable/terrascan/releases/download/v1.18.11/terrascan_1.18.11_Linux_x86_64.tar.gz" -o terrascan.tar.gz

# Extract
tar -xf terrascan.tar.gz terrascan

# Make executable and move to PATH
chmod +x terrascan
sudo mv terrascan /usr/local/bin/

# Verify installation
terrascan version
```

### macOS
```bash
# Using Homebrew
brew install terrascan

# Verify installation
terrascan version
```

### Windows
1. Download the Windows binary from: https://github.com/tenable/terrascan/releases
2. Extract the ZIP file
3. Add the extracted directory to your system PATH
4. Verify: `terrascan version`

## Common Commands

### Basic Scan
```bash
# Scan current directory
terrascan scan

# Scan specific directory
terrascan scan -d /path/to/terraform

# Scan specific IaC type
terrascan scan -i terraform
terrascan scan -i kubernetes
terrascan scan -i helm
```

### Output Formats
```bash
# Human-readable format (default)
terrascan scan -o human

# JSON format
terrascan scan -o json

# YAML format
terrascan scan -o yaml

# SARIF format (for GitHub)
terrascan scan -o sarif

# JUnit XML format (for Jenkins)
terrascan scan -o junit-xml
```

### Filtering

```bash
# Filter by severity
terrascan scan --severity high

# Skip specific rules
terrascan scan --skip-rules="AWS.S3Bucket.DS.High.1041,AWS.EC2.NS.High.0580"

# Scan specific files only
terrascan scan --iac-file main.tf
```

### Advanced Options

```bash
# Use configuration file
terrascan scan --config-path terrascan-config.toml

# Verbose output
terrascan scan --verbose

# Show passed rules as well
terrascan scan --show-passed

# Scan all IaC types
terrascan scan --iac-type all
```

## Jenkins Integration

### Jenkinsfile Stage
```groovy
stage('Terrascan Security Scan') {
    steps {
        script {
            sh '''
                # Install if needed
                if ! command -v terrascan &> /dev/null; then
                    curl -L "https://github.com/tenable/terrascan/releases/download/v1.18.11/terrascan_1.18.11_Linux_x86_64.tar.gz" -o terrascan.tar.gz
                    tar -xf terrascan.tar.gz terrascan
                    chmod +x terrascan
                    export PATH=$PATH:$(pwd)
                fi
                
                # Run scan
                ./terrascan scan --iac-type all --verbose --output human
            '''
        }
    }
}
```

## Configuration File Examples

### Basic Configuration (terrascan-config.toml)
```toml
[scan]
  severity = "medium"
  skip-rules = []
  categories = [
    "Identity and Access Management",
    "Data Protection"
  ]

[output]
  format = "json"
```

### Skip Specific Rules
```toml
[scan]
  skip-rules = [
    "AWS.S3Bucket.DS.High.1041",
    "AWS.EC2.NetworkSecurity.High.0580",
    "kubernetes.pod.security.high.0580"
  ]
```

## Common Error Solutions

### 1. Command Not Found
```
terrascan: command not found
```
**Solution**: Install terrascan or add it to PATH

### 2. No IaC Files Found
```
no IaC files found
```
**Solution**: Ensure you have .tf, .yaml, or other IaC files in the scan directory

### 3. Permission Denied
```
permission denied: ./terrascan
```
**Solution**: `chmod +x terrascan`

## Severity Levels

- **HIGH**: Critical security issues that should be fixed immediately
- **MEDIUM**: Important security issues that should be addressed
- **LOW**: Minor issues or best practice violations

## Common Rule Categories

1. **Identity and Access Management**: IAM policies, roles, permissions
2. **Data Protection**: Encryption, data handling
3. **Infrastructure Security**: Network security, firewalls
4. **Logging and Monitoring**: Audit logs, monitoring
5. **Resilience**: Backup, disaster recovery
6. **Compliance Validation**: Regulatory compliance

## Useful Links

- Official Documentation: https://runterrascan.io/
- GitHub Repository: https://github.com/tenable/terrascan
- Policy Documentation: https://runterrascan.io/docs/policies/
- Jenkins Integration: https://runterrascan.io/docs/integrations/jenkins/

## Tips

1. **Start with high severity**: Focus on fixing HIGH severity issues first
2. **Use configuration files**: Keep scan configuration in version control
3. **Integrate early**: Add to CI/CD pipeline from the start
4. **Review regularly**: Re-scan after fixing issues
5. **Document exceptions**: If skipping rules, document why in code comments
6. **Use output formats**: JSON/SARIF for automation, human for review

## Example Workflow

```bash
# 1. Initial scan to see all issues
terrascan scan -o human > scan-results.txt

# 2. Review high severity issues
terrascan scan --severity high

# 3. Fix issues and rescan
# ... make fixes ...
terrascan scan --severity high

# 4. Generate report for CI/CD
terrascan scan -o junit-xml > terrascan-report.xml
```
