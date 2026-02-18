pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "moshindevops11/django-rest-app"
        EC2_IP = "16.170.249.190"
        CONTAINER_NAME = "django-app"
    }

    stages {

        stage('Clean Workspace') {
            steps {
                deleteDir()
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:latest ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                        docker push ${DOCKER_IMAGE}:latest
                        docker logout
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ubuntu@${EC2_IP} '
                        set -e
                        sudo docker pull ${DOCKER_IMAGE}:latest
                        sudo docker rm -f ${CONTAINER_NAME} || true
                        sudo docker run -d --name ${CONTAINER_NAME} -p 8000:8000 -v /home/ubuntu/media:/app/media --restart unless-stopped ${DOCKER_IMAGE}:latest
                        echo "Deployment Successful"
                    '
                    """
                }
            }
        }

        stage('Debug') {
            steps {
                sh "echo DEPLOY VERSION 2.0"
            }
        }
    }
}
