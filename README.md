# PR Secret Detection Setup

This repository is configured to automatically scan for secrets when pull requests are created.

## Features

- 🔍 Automatic secret detection using Gitleaks
- ✅ Runs on every PR opened, synchronized, or reopened
- 🚀 Integrated with GitHub Actions for seamless automation
- 🔧 Optional Jenkins integration

## How It Works

### GitHub Actions (Recommended)

When you create a pull request, the **Secret Detection with Gitleaks** workflow automatically:

1. Checks out your code
2. Downloads and installs Gitleaks
3. Scans your changes for potential secrets
4. Reports any findings

The workflow is triggered on:
- Pull requests to `main` or `master` branches
- Push events to `main` or `master` branches

### Jenkins Integration (Optional)

If you have a Jenkins server configured, you can also trigger Jenkins pipelines:

1. Add the following secrets to your GitHub repository:
   - `JENKINS_URL`: Your Jenkins server URL (e.g., `https://jenkins.example.com`)
   - `JENKINS_USER`: Your Jenkins username
   - `JENKINS_TOKEN`: Your Jenkins API token
   - `JENKINS_JOB_NAME`: The name of your Jenkins job

2. The **Trigger Jenkins Pipeline** workflow will automatically call your Jenkins server when PRs are created

## Authentication Setup

### For GitHub Actions

GitHub Actions uses the built-in `GITHUB_TOKEN` automatically - no additional setup required!

### For Jenkins

If you want Jenkins integration, you need to:

1. **Create a Jenkins API Token:**
   - Log in to Jenkins
   - Click your username → Configure
   - Under "API Token", click "Add new Token"
   - Copy the generated token

2. **Add Credentials in Jenkins:**
   - Go to "Manage Jenkins" → "Manage Credentials"
   - Add GitHub credentials with ID: `github-credentials`
   - Use either:
     - Username/password (GitHub username + personal access token)
     - Or SSH key

3. **Add Secrets to GitHub:**
   - Go to your repository on GitHub
   - Navigate to Settings → Secrets and variables → Actions
   - Add the required secrets mentioned above

## Troubleshooting

### "Authentication Error" in Jenkins

**Problem:** Jenkins cannot authenticate to GitHub to checkout code.

**Solution:**
1. Verify that Jenkins has valid GitHub credentials configured
2. Check that the credential ID matches the one in the Jenkinsfile (default: `github-credentials`)
3. Ensure the credential has appropriate permissions to access the repository
4. Update the `GIT_CREDENTIALS_ID` environment variable in Jenkins if using a different credential ID

### PR Not Triggering Secret Detection

**Problem:** Creating a PR doesn't trigger the secret scan.

**Solutions:**
1. **For GitHub Actions:** Check that workflows are enabled in your repository settings
2. **For Jenkins:** Ensure GitHub webhook is configured to point to your Jenkins server
3. Verify that the workflow files exist in `.github/workflows/` directory
4. Check the Actions tab on GitHub to see if workflows are running

### Secrets Detected

**Problem:** The workflow fails because secrets were detected in your code.

**What to do:**
1. Review the workflow logs to see what was detected
2. Remove any actual secrets from your code
3. Use environment variables or secret management tools instead
4. If it's a false positive, update the `gitleaks.toml` configuration to exclude it
5. Push your changes and the workflow will run again

## Configuration

### Customizing Gitleaks Rules

Edit the `gitleaks.toml` file to customize what patterns Gitleaks should detect:

```toml
[[rules]]
id = "my-custom-rule"
description = "My custom secret pattern"
regex = '''pattern-here'''
tags = ["secret"]
```

### Changing Target Branches

Edit `.github/workflows/secret-detection.yml` to change which branches trigger the scan:

```yaml
on:
  pull_request:
    branches:
      - main
      - develop  # Add more branches
```

## Manual Testing

You can also run Gitleaks locally:

```bash
# Download Gitleaks (check for latest version at https://github.com/gitleaks/gitleaks/releases)
GITLEAKS_VERSION="v8.18.2"
VERSION_NUM="${GITLEAKS_VERSION#v}"
curl -sSL "https://github.com/gitleaks/gitleaks/releases/download/${GITLEAKS_VERSION}/gitleaks_${VERSION_NUM}_linux_x64.tar.gz" -o gitleaks.tar.gz
tar -xzf gitleaks.tar.gz

# Run scan
./gitleaks detect --source . --config gitleaks.toml --verbose
```

Or use the provided script:

```bash
chmod +x scripts/run_gitleaks.sh
./scripts/run_gitleaks.sh
```

## Files Overview

- `.github/workflows/secret-detection.yml` - Main GitHub Actions workflow for secret scanning
- `.github/workflows/trigger-jenkins.yml` - Optional Jenkins integration workflow
- `Jenkinsfile` - Jenkins pipeline configuration (if using Jenkins)
- `gitleaks.toml` - Gitleaks configuration with custom rules
- `scripts/run_gitleaks.sh` - Script to run Gitleaks manually

## Support

For issues or questions:
1. Check the Actions tab for workflow run details
2. Review Jenkins console output (if using Jenkins)
3. Check gitleaks documentation: https://github.com/gitleaks/gitleaks
