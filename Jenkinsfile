pipeline {
    agent any
    environment {
        docker_registry = ""
    }
    stages {
        stage('Build') {
            steps {
                echo 'Building..'
                sh 'docker build -t registry:5000/java-app .'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Push') {
            steps {
                echo 'Push....'
                sh 'docker push registry:5000/java-app'
            }
        }
    }
}