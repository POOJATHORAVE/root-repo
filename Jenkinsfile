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
                // Run your Gitleaks scanning script
                sh 'scripts/run_gitleaks.sh'
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
