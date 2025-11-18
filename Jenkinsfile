pipeline {
    agent any

    // Trigger Jenkins build automatically on GitHub push
    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the repository
                checkout scm
            }
        }

        stage('Gitleaks Scan') {
            steps {
                // Ensure the script is executable
                sh 'chmod +x scripts/run_gitleaks.sh'
                
                // Run your Gitleaks scanning script
                sh 'bash scripts/run_gitleaks.sh'
            }
        }
    }

    post {
        success {
            echo "No secrets detected. Scan passed!"
        }
        failure {
            echo "Secrets detected! Blocking PR merge."
        }
    }
}
