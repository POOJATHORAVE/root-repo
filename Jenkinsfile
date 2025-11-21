pipeline {
    agent any

    environment {
        GITLEAKS_VERSION = "v8.18.2"
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    // Checkout with credentials for authentication
                    checkout([
                        $class: 'GitSCM',
                        branches: scm.branches,
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [[$class: 'CloneOption', depth: 0, noTags: false, reference: '', shallow: false]],
                        userRemoteConfigs: [[
                            credentialsId: env.GIT_CREDENTIALS_ID ?: 'github-credentials',
                            url: scm.userRemoteConfigs[0].url
                        ]]
                    ])
                }
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
                        # Download Gitleaks
                        curl -sSL "https://github.com/gitleaks/gitleaks/releases/download/${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION#v}_linux_x64.tar.gz" -o gitleaks.tar.gz
                        tar -xzf gitleaks.tar.gz
                        chmod +x gitleaks
                        
                        # Run Gitleaks with config if available
                        if [ -f gitleaks.toml ]; then
                            echo "Using gitleaks.toml configuration"
                            ./gitleaks detect --source . --config gitleaks.toml --verbose --redact --exit-code 1
                        else
                            echo "Using default configuration"
                            ./gitleaks detect --source . --verbose --redact --exit-code 1
                        fi
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