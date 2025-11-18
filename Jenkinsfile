pipeline {
    agent any

    // Trigger Jenkins build automatically on GitHub push
    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the repository1
                checkout scm
            }
        }

        stage('Gitleaks Scan') {
            steps {
                // Make sure the script is executable inside Jenkins
                sh 'chmod +x scripts/run_gitleaks.sh'

                // Run the Gitleaks scanning script
                sh './scripts/run_gitleaks.sh'
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

 