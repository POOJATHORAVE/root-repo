# Terrascan Jenkins Integration - Visual Guide

## Pipeline Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Jenkins Pipeline                             │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │   Stage 1: Checkout    │
                    │   (Clone Repository)   │
                    └────────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │  Stage 2: PR Info      │
                    │  (Display PR Details)  │
                    └────────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │ Stage 3: Secret Scan   │
                    │     (Gitleaks)         │
                    │  ✓ Detect Secrets      │
                    └────────────────────────┘
                                 │
                                 ▼
        ┌────────────────────────────────────────────────┐
        │    Stage 4: Terrascan Security Scan (NEW!)    │
        │  ┌──────────────────────────────────────────┐ │
        │  │ 1. Check if Terrascan installed          │ │
        │  │ 2. Download & Install if needed          │ │
        │  │ 3. Load terrascan-config.toml            │ │
        │  │ 4. Run security scan on all IaC files    │ │
        │  │ 5. Generate scan reports                 │ │
        │  └──────────────────────────────────────────┘ │
        │                                                │
        │  Scans: ✓ Terraform  ✓ Kubernetes            │
        │         ✓ Helm       ✓ Docker                 │
        │         ✓ CloudFormation  ✓ ARM               │
        └────────────────────────────────────────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                    ▼                         ▼
            ┌──────────────┐        ┌──────────────┐
            │  Violations  │        │  No Issues   │
            │    Found     │        │              │
            └──────────────┘        └──────────────┘
                    │                         │
                    ▼                         ▼
            ┌──────────────┐        ┌──────────────┐
            │   Pipeline   │        │    Stage 5   │
            │    FAILS     │        │    Build     │
            │              │        │ (Conditional)│
            └──────────────┘        └──────────────┘
                    │                         │
                    └────────────┬────────────┘
                                 ▼
                    ┌────────────────────────┐
                    │     Post Actions       │
                    │  • Archive Reports     │
                    │  • Send Notifications  │
                    └────────────────────────┘
```

## File Structure & Relationships

```
root-repo/
│
├── Jenkinsfile ──────────────────┐
│   (Pipeline Definition)         │
│   • Defines stages              │ References
│   • Calls scripts                │
│   • Archives reports            │
│                                  ▼
├── terrascan-config.toml ─────────────┐
│   (Terrascan Configuration)          │ Used by
│   • Severity levels                  │
│   • Skip rules                       │
│   • Output format                    │
│                                      ▼
├── scripts/                    ┌──────────────────┐
│   ├── run_gitleaks.sh         │ run_terrascan.sh │◄────┐
│   └── run_terrascan.sh ───────┤  (Scanner)       │     │
│       (Terrascan Executor)    │  • Validates     │     │
│       • Checks installation   │  • Configures    │  Executes
│       • Runs scans            │  • Scans         │     │
│       • Formats output        │  • Reports       │     │
│                               └──────────────────┘     │
│                                      │                 │
├── terraform/ ◄─────────────────────┘                 │
│   ├── main.tf                    Scans these         │
│   └── kubernetes-example.yaml       files            │
│       (Sample IaC Files)                              │
│                                                       │
├── Documentation                                       │
│   ├── README.md                                      │
│   │   (Main Guide)                                   │
│   │   • Installation                                 │
│   │   • Usage                                        │
│   │   • Troubleshooting                              │
│   │                                                   │
│   ├── TERRASCAN_GUIDE.md                            │
│   │   (Quick Reference)                              │
│   │   • Commands                                     │
│   │   • Configuration                                │
│   │   • Examples                                     │
│   │                                                   │
│   └── IMPLEMENTATION_SUMMARY.md                      │
│       (Technical Details)                             │
│       • Architecture                                  │
│       • Integration points                           │
│       • Testing status                               │
│                                                       │
└── .gitignore                                          │
    (Ignore Rules)                                      │
    • Build artifacts ──────────────────────────────────┘
    • Scan reports
    • Binaries
```

## Scan Process Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Terrascan Scan Process                    │
└─────────────────────────────────────────────────────────────┘

1. Initialize
   ├── Check Terrascan installation
   ├── Load configuration (terrascan-config.toml)
   └── Validate scan parameters

2. Discovery
   ├── Scan directory for IaC files
   ├── Identify file types:
   │   ├── *.tf (Terraform)
   │   ├── *.yaml/*.yml (Kubernetes, Helm)
   │   ├── Dockerfile (Docker)
   │   ├── *.json (CloudFormation)
   │   └── *.template (ARM)
   └── Queue files for analysis

3. Analysis
   ├── Parse IaC files
   ├── Apply 500+ security policies
   ├── Check against:
   │   ├── Identity & Access Management
   │   ├── Data Protection
   │   ├── Infrastructure Security
   │   ├── Logging & Monitoring
   │   ├── Resilience
   │   └── Compliance
   └── Identify violations

4. Reporting
   ├── Generate scan report
   ├── Format output (human/json/yaml/sarif)
   ├── Display violations:
   │   ├── Severity (HIGH/MEDIUM/LOW)
   │   ├── File & line number
   │   ├── Rule ID
   │   ├── Description
   │   └── Remediation advice
   └── Return exit code

5. Post-Processing
   ├── Archive reports in Jenkins
   ├── Fail pipeline if violations found
   └── Send notifications (optional)
```

## Security Categories Covered

```
┌─────────────────────────────────────────────────────────────┐
│              Terrascan Security Categories                   │
└─────────────────────────────────────────────────────────────┘

┌──────────────────────────────┐
│ Identity & Access Management │ ─── • IAM policies
│                               │     • Role permissions
│  ✓ IAM Policies               │     • Access controls
│  ✓ User Permissions           │     • Authentication
│  ✓ Service Roles              │
│  ✓ Access Controls            │
└──────────────────────────────┘

┌──────────────────────────────┐
│      Data Protection          │ ─── • Encryption at rest
│                               │     • Encryption in transit
│  ✓ Encryption Settings        │     • Data handling
│  ✓ Storage Security           │     • Backup policies
│  ✓ Database Protection        │
│  ✓ Secrets Management         │
└──────────────────────────────┘

┌──────────────────────────────┐
│   Infrastructure Security     │ ─── • Network configs
│                               │     • Firewall rules
│  ✓ Network Configuration      │     • Port exposure
│  ✓ Firewall Rules             │     • VPC settings
│  ✓ Security Groups            │
│  ✓ Public Access              │
└──────────────────────────────┘

┌──────────────────────────────┐
│   Logging & Monitoring        │ ─── • Audit logs
│                               │     • CloudTrail
│  ✓ Audit Logging              │     • Monitoring setup
│  ✓ CloudWatch/Monitoring      │     • Alert configs
│  ✓ Log Retention              │
│  ✓ Alerting                   │
└──────────────────────────────┘

┌──────────────────────────────┐
│        Resilience             │ ─── • Backup configs
│                               │     • Redundancy
│  ✓ Backup Configuration       │     • Disaster recovery
│  ✓ High Availability          │     • Multi-AZ setup
│  ✓ Disaster Recovery          │
│  ✓ Versioning                 │
└──────────────────────────────┘

┌──────────────────────────────┐
│  Compliance Validation        │ ─── • PCI-DSS
│                               │     • HIPAA
│  ✓ PCI-DSS                    │     • GDPR
│  ✓ HIPAA                      │     • CIS benchmarks
│  ✓ GDPR                       │
│  ✓ CIS Benchmarks             │
└──────────────────────────────┘
```

## Usage Examples

### Local Testing
```bash
# Basic scan
./scripts/run_terrascan.sh

# Scan specific directory
./scripts/run_terrascan.sh ./terraform

# Generate JSON report
./scripts/run_terrascan.sh . terrascan-config.toml json

# Direct terrascan command
terrascan scan -i terraform -d ./terraform --verbose
```

### Jenkins Execution
```
Pipeline starts automatically on:
├── Push to main branch
├── Pull request creation
└── Manual trigger

Terrascan executes:
├── Downloads binary (first run only)
├── Scans all IaC files
├── Reports violations
└── Archives results
```

## Output Example

```
========================================
Running Terrascan Security Scan
========================================

Scanning directory: ./terraform
Configuration file: terrascan-config.toml
Output format: human

Terrascan version: v1.18.11

Violation Details -
    
  Description    :  Ensure S3 bucket has server-side encryption
  File           :  terraform/main.tf
  Line           :  34
  Severity       :  HIGH
  Rule Name      :  s3Encryption
  Rule ID        :  AWS.S3Bucket.DS.High.1041
  Category       :  Data Protection
  
  Remediation    :  Enable server-side encryption for S3 bucket
  
========================================
❌ Terrascan scan found violations
Exit code: 3
========================================
```

## Benefits

```
┌────────────────────────────────────────────────────────┐
│                    Benefits                             │
├────────────────────────────────────────────────────────┤
│ ✅ Early Detection        │ Find issues before deploy  │
│ ✅ Automated Scanning     │ No manual intervention     │
│ ✅ Multi-Cloud Support    │ AWS, Azure, GCP, K8s       │
│ ✅ Comprehensive Policies │ 500+ security rules        │
│ ✅ CI/CD Integration      │ Seamless Jenkins workflow  │
│ ✅ Clear Reporting        │ Actionable violation info  │
│ ✅ Configurable           │ Customize to your needs    │
│ ✅ Open Source            │ Free and community-backed  │
└────────────────────────────────────────────────────────┘
```

## Next Steps

1. ✅ Review README.md for detailed instructions
2. ✅ Customize terrascan-config.toml for your requirements
3. ✅ Test locally: `./scripts/run_terrascan.sh`
4. ✅ Push to trigger Jenkins pipeline
5. ✅ Review scan results in Jenkins artifacts
6. ✅ Fix violations and re-run
7. ✅ Adjust skip-rules if needed for false positives

---

*For more information, see README.md and TERRASCAN_GUIDE.md*
