pipeline {
    agent any

    environment {
        GITLEAKS_VERSION = "v8.18.2"
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
            echo "❌ Pipeline failed. Secrets detected or build error."
        }
    }
}