pipeline {
    agent any

    environment {
        GITLEAKS_VERSION = "v8.18.2"
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the branch from webhook payload
                checkout scm
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

        stage('Build') {
            when {
                expression {
                    // Only run build if target branch is 'develop'
                    def targetBranch = env.CHANGE_TARGET ?: env.GIT_BRANCH
                    return targetBranch == 'main'
                }
            }
            steps {
                echo "Building for PR targeting develop branch..."
                // Add your build steps here
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully."
        }
        failure {
            echo "❌ Pipeline failed. Secrets detected or build error."
        }
    }
}