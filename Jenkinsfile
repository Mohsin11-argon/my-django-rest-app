pipeline {
    agent any

    environment {
        // Apne Docker Hub username aur repo ka naam yahan likhein
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
                // Docker image build ho rahi hai
                sh "docker build -t ${DOCKER_IMAGE}:latest ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                // Docker Hub par login aur push
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                // EC2 par login karke purani image delete aur nayi run karna
                sshagent(['ec2-ssh-key']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ubuntu@${EC2_IP} "
                        sudo docker pull ${DOCKER_IMAGE}:latest
                        sudo docker stop django-app || true
                        sudo docker rm django-app || true
                        sudo docker run -d --name django-app -p 80:8000 ${DOCKER_IMAGE}:latest
                    "
                    """
                }
            }
        }
    }
}