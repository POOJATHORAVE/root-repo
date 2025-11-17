pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Gitleaks Scan') {
            steps {
                sh 'scripts/run_gitleaks.sh'
            }
        }
    }

    post {
        failure {
            echo "Secrets detected! Blocking PR merge."
        }
    }
}