pipeline {
    agent any

    environment {
        GITLEAKS_VERSION = "v8.18.2"
        TERRASCAN_VERSION = "v1.18.11"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Show PR Info') {
            steps {
                echo "PR Number: ${env.CHANGE_ID}"
                echo "Base Branch: ${env.CHANGE_TARGET}"
                echo "Feature Branch: ${env.CHANGE_BRANCH}"
            }
        }

        stage('Secret Scan') {
            steps {
                script {
                    echo "Running secret scan with Gitleaks..."
                    sh '''
                        curl -sSL https://github.com/gitleaks/gitleaks/releases/download/${GITLEAKS_VERSION}/gitleaks-linux-amd64 -o gitleaks
                        chmod +x gitleaks
                        ./gitleaks detect --source . --verbose --redact --exit-code 1
                    '''
                }
            }
        }

        stage('Terrascan Security Scan') {
            steps {
                script {
                    echo "Running Terrascan security scan..."
                    sh '''
                        # Install Terrascan if not already installed
                        if ! command -v terrascan &> /dev/null; then
                            echo "Installing Terrascan ${TERRASCAN_VERSION}..."
                            curl -L "https://github.com/tenable/terrascan/releases/download/${TERRASCAN_VERSION}/terrascan_${TERRASCAN_VERSION#v}_Linux_x86_64.tar.gz" -o terrascan.tar.gz
                            tar -xf terrascan.tar.gz terrascan
                            chmod +x terrascan
                            # Try to install in system paths, fallback to current directory
                            sudo mv terrascan /usr/local/bin/ 2>/dev/null || \
                            mv terrascan /usr/bin/ 2>/dev/null || \
                            echo "Terrascan installed in current directory"
                        fi
                        
                        # Run Terrascan using the helper script
                        chmod +x scripts/run_terrascan.sh
                        # Use ./terrascan directly if not in PATH
                        if ! command -v terrascan &> /dev/null && [ -f ./terrascan ]; then
                            export PATH=$PATH:$(pwd)
                        fi
                        ./scripts/run_terrascan.sh . terrascan-config.toml human
                    '''
                }
            }
        }

        stage('Build') {
            when {
                expression {
                    // Only run build if PR targets 'main'
                    def targetBranch = env.CHANGE_TARGET ?: env.GIT_BRANCH
                    return targetBranch == 'main'
                }
            }
            steps {
                echo "Building for PR targeting main branch..."
                // Add your build steps here
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully."
        }
        failure {
            echo "❌ Pipeline failed. Secrets detected, security violations found, or build error."
        }
        always {
            // Archive scan reports if they exist
            archiveArtifacts artifacts: '**/terrascan-report.*', allowEmptyArchive: true
        }
    }
}