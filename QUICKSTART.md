# Terrascan Integration - Quick Start Guide

🚀 **Get started with Terrascan in 5 minutes!**

## Prerequisites
- Jenkins server with pipeline support
- Git access to this repository
- Internet access (for Terrascan download)

## Step 1: Install Terrascan Locally (Optional but Recommended)

### Linux/macOS
```bash
curl -L "https://github.com/tenable/terrascan/releases/download/v1.18.11/terrascan_1.18.11_Linux_x86_64.tar.gz" -o terrascan.tar.gz
tar -xf terrascan.tar.gz terrascan
chmod +x terrascan
sudo mv terrascan /usr/local/bin/
terrascan version
```

### macOS (Homebrew)
```bash
brew install terrascan
terrascan version
```

## Step 2: Test Locally

```bash
# Clone the repository
git clone https://github.com/POOJATHORAVE/root-repo.git
cd root-repo

# Run the scan script
chmod +x scripts/run_terrascan.sh
./scripts/run_terrascan.sh

# Expected output: Scan results for sample Terraform files
```

## Step 3: Configure (Optional)

Edit `terrascan-config.toml` to customize:

```toml
[scan]
  severity = "medium"  # Options: low, medium, high
  skip-rules = []      # Add rule IDs to skip

[output]
  format = "json"      # Options: json, yaml, human, sarif, junit-xml
```

## Step 4: Set Up Jenkins Pipeline

### Option A: Create New Pipeline Job
1. Open Jenkins
2. Click "New Item"
3. Enter name: "Terrascan-Security-Scan"
4. Select "Pipeline"
5. Click "OK"

### Option B: Configure Pipeline
1. In "Pipeline" section, select "Pipeline script from SCM"
2. SCM: Git
3. Repository URL: `https://github.com/POOJATHORAVE/root-repo.git`
4. Script Path: `Jenkinsfile`
5. Save

## Step 5: Run the Pipeline

1. Click "Build Now"
2. Watch the console output
3. The pipeline will:
   - ✅ Checkout code
   - ✅ Show PR info
   - ✅ Run secret scan (Gitleaks)
   - ✅ **Run Terrascan security scan**
   - ✅ Build (if targeting main)

## Step 6: Review Results

### If Scan Passes ✅
```
========================================
✅ Terrascan scan completed successfully
========================================
Pipeline: SUCCESS
```

### If Violations Found ❌
```
Violation Details -
  Description    :  Security issue found
  File           :  terraform/main.tf
  Line           :  34
  Severity       :  HIGH
  Rule ID        :  AWS.S3.123
  
Pipeline: FAILED
```

## Step 7: Fix Issues (If Any)

1. Check the Jenkins console output for violation details
2. Open the file mentioned in the violation
3. Go to the line number specified
4. Follow the remediation advice
5. Commit and push changes
6. Pipeline runs automatically

## Common Commands

```bash
# Scan current directory
./scripts/run_terrascan.sh

# Scan specific directory
./scripts/run_terrascan.sh ./terraform

# Generate JSON report
./scripts/run_terrascan.sh . terrascan-config.toml json

# Direct terrascan command
terrascan scan -i terraform -d ./terraform
```

## Troubleshooting

### "Terrascan not found"
**Solution**: Install Terrascan (see Step 1) or let Jenkins install it automatically

### "Permission denied"
**Solution**: 
```bash
chmod +x scripts/run_terrascan.sh
```

### "No IaC files found"
**Solution**: Add .tf, .yaml, or other IaC files to your repository

## What Gets Scanned?

Terrascan automatically detects and scans:
- ✅ **Terraform** (.tf files)
- ✅ **Kubernetes** (.yaml, .yml files)
- ✅ **Helm** charts
- ✅ **Docker** (Dockerfile)
- ✅ **CloudFormation** (.json, .yaml)
- ✅ **Azure ARM** (.json templates)

## Next Steps

1. 📖 Read full documentation: [README.md](README.md)
2. 📚 Check command reference: [TERRASCAN_GUIDE.md](TERRASCAN_GUIDE.md)
3. 🏗️ Review architecture: [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)
4. 📊 See diagrams: [INTEGRATION_DIAGRAM.md](INTEGRATION_DIAGRAM.md)
5. ⚙️ Customize configuration: [terrascan-config.toml](terrascan-config.toml)

## Quick Tips

💡 **Tip 1**: Start with `severity = "high"` to focus on critical issues first

💡 **Tip 2**: Use `--show-passed` to see what's working correctly:
```bash
terrascan scan --show-passed
```

💡 **Tip 3**: Generate reports for later review:
```bash
./scripts/run_terrascan.sh . terrascan-config.toml json > report.json
```

💡 **Tip 4**: Skip specific rules if they're false positives:
```toml
[scan]
  skip-rules = ["AWS.S3Bucket.DS.High.1041"]
```

💡 **Tip 5**: Check scan results in Jenkins artifacts after each run

## Support

- 📖 [Terrascan Official Docs](https://runterrascan.io/)
- 💬 [Terrascan GitHub Issues](https://github.com/tenable/terrascan/issues)
- 📝 [Jenkins Pipeline Docs](https://www.jenkins.io/doc/book/pipeline/)

## Success Checklist

- [ ] Terrascan installed locally
- [ ] Successfully ran local scan
- [ ] Jenkins pipeline configured
- [ ] First pipeline run completed
- [ ] Understood how to read scan results
- [ ] Know how to fix violations
- [ ] Configured custom settings (optional)

---

**🎉 Congratulations! You're now using Terrascan to secure your Infrastructure as Code!**

For detailed information, see [README.md](README.md)
