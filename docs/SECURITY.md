# Security Documentation for Golden/Bakery RHEL Images

## Overview

This document outlines the security features and best practices implemented in the AWS Golden/Bakery RHEL Image solution.

## Security Features

### 1. Image Encryption
- All AMIs use encrypted EBS snapshots
- Encryption handled via AWS KMS keys
- Uses AES-256 encryption for data security

### 2. CIS Hardening
- CIS Level 1 Benchmark applied to all images
- Automated compliance testing during build
- Regular updates to maintain compliance

### 3. IMDSv2 Enforcement
- All instances launched from golden images enforce IMDSv2
- Prevents SSRF attacks via metadata service

### 4. Network Security
- No default security groups used
- Custom security groups with minimal access
- Private subnet deployment only
- VPC endpoints for AWS service access

### 5. IAM Security
- Principle of least privilege
- Role-based access control
- No long-term credentials in images
- Service roles for automation

### 6. Image Access Control
- Private images by default
- Account-wide blocking of public sharing
- Controlled sharing via launch permissions
- Service Control Policies for compliance

### 7. Logging and Monitoring
- CloudWatch logging for all build activities
- EventBridge for state changes
- SNS notifications for security events
- AWS Config for change tracking

## Security Agents

### Installed Agents
1. **SSM Agent**: Secure remote access
2. **Qualys Agent**: Vulnerability scanning
3. **Datadog Agent**: Security monitoring
4. **CloudWatch Agent**: Log collection
5. **Defender for Endpoint**: EDR capabilities (via Azure Arc)
6. **Azure Arc**: Cloud security posture management

## Compliance

### CIS Benchmarks
- RHEL 8: CIS Red Hat Enterprise Linux 8 Benchmark v3.0.0
- RHEL 9: CIS Red Hat Enterprise Linux 9 Benchmark v2.0.0

### Testing Process
1. Automated CIS compliance testing during build
2. Qualys vulnerability scanning post-build
3. Defender for Cloud security assessment
4. Manual validation of critical controls

## Vulnerability Management

### Patching Schedule
- Weekly automated builds with latest patches
- Monthly security review (3rd Monday)
- Emergency patches for critical vulnerabilities

### Scanning Process
1. Image built with latest updates
2. Test instance launched
3. Qualys agent reports to tenant
4. Vulnerability scan performed
5. Findings remediated
6. Re-scan to verify fixes
7. Image released for production

## Incident Response

### Security Events
- Image build failures
- Unauthorized access attempts
- Compliance violations
- Vulnerability detections

### Notification Channels
- SNS email alerts
- CloudWatch alarms
- Security team escalation

## Best Practices

### For Operations Teams
1. Subscribe to SNS notifications
2. Monitor CloudWatch logs regularly
3. Review Qualys scan reports
4. Keep image lifecycle current
5. Document all changes

### For Security Teams
1. Review CIS compliance reports
2. Validate vulnerability remediation
3. Audit image sharing permissions
4. Monitor for unauthorized images
5. Update security baselines

### For Development Teams
1. Use only approved golden images
2. Do not modify security configurations
3. Report vulnerabilities promptly
4. Follow tagging standards
5. Maintain IMDSv2 enforcement

## Secrets Management

### Sensitive Data
- Never embed credentials in images
- Use AWS Secrets Manager for secrets
- Rotate credentials regularly
- Use IAM roles for service access

### Example: Retrieving Secrets
```bash
# Retrieve from Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id qualys-credentials \
  --query SecretString \
  --output text
```

## Audit and Compliance

### Tracking Changes
- Git version control for IaC
- AWS Config for resource changes
- CloudTrail for API calls
- Image Builder version history

### Compliance Reports
- Monthly CIS compliance status
- Quarterly vulnerability assessment
- Annual security audit
- Regular penetration testing

## Contact Information

- **Security Incidents**: Zensar Security Team
- **Vulnerability Reports**: asif.ahmed@tescoims.com
- **Compliance Questions**: Design Assurance Forum

## References

- CIS Benchmarks: https://www.cisecurity.org/cis-benchmarks
- AWS Security Best Practices: https://docs.aws.amazon.com/security/
- NIST Framework: https://www.nist.gov/cyberframework
