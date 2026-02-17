pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "moshindevops11/django-rest-app"
        EC2_IP = "16.170.249.190"
    }

    stages {
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
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    // Yahan hum ne nested ssh hata diya hai aur commands ko clean kiya hai
                    sh """
                    ssh -o StrictHostKeyChecking=no ubuntu@${EC2_IP} "
                        sudo docker pull ${DOCKER_IMAGE}:latest
                        sudo docker stop django-app || true
                        sudo docker rm django-app || true
                        sudo docker run -d --name django-app -p 8000:8000 ${DOCKER_IMAGE}:latest
                    "
                    """
                }
            }
        }
    }
}