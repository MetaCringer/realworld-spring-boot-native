pipeline {
    agent any
    stages {
        stage('Clone repo') {
            steps {
                git 'https://github.com/MetaCringer/realworld-spring-boot-native'
            }
        }
        stage('Build') {
            steps {
                echo 'Building..'
                sh 'docker build -t registry:5000/java-app .'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
                snykSecurity failOnIssues: false, snykInstallation: 'main', snykTokenId: 'snyk'
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