pipeline {
    agent any
    tools {
        jdk "${JDK_TOOL}"
        dockerTool "${DOCKER_TOOL}"
        snyk "${SNYK_TOOL}"
    }
    stages {
        stage('Clone repo') {
            steps {
                git "${REPO}"
                script{
                    env.VERSION_NUMBER = VersionNumber(versionNumberString: '${BUILD_YEAR}.${BUILD_MONTH}.${BUILD_DAY}.${BUILDS_TODAY}')
                    currentBuild.displayName = "${VERSION_NUMBER}"
                }
            }
        }
        stage('Build') {
            steps {   
                echo 'Building..'
                sh "docker build -t ${IMAGE_TAG}:${VERSION_NUMBER} ."
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
                snykSecurity failOnIssues: false, snykInstallation: "${SNYK_TOOL}", snykTokenId: "${SNYK_TOKEN_ID}"
                sh "trivy image --output cve_report.txt --timeout 60m ${IMAGE_TAG}:${VERSION_NUMBER}"
                withCredentials([usernamePassword(credentialsId: "${ARTIFACTORY_TOKEN_ID}", usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh 'curl -u${USERNAME}:${PASSWORD} -T $JENKINS_HOME/jobs/jobs/${JOB_NAME}/builds/${BUILD_NUMBER}/archive/*.html "${ARTIFACTORY_URL}/artifactory/example-repo-local/${JOB_NAME}/snyk_report_${VERSION_NUMBER}.html"'
                    sh 'curl -u${USERNAME}:${PASSWORD} -T cve_report.txt "${ARTIFACTORY_URL}/artifactory/example-repo-local/${JOB_NAME}/trivy_report_${VERSION_NUMBER}.txt"'
                }
            }
        }
        stage('Push') {
            steps {
                echo 'Push....'
                sh 'docker push ${IMAGE_TAG}:${VERSION_NUMBER}'
            }
        }
    }
}