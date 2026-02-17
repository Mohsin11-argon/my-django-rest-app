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
                    sh """
                    ssh -o StrictHostKeyChecking=no ubuntu@${EC2_IP} "
                        # Nayi image pull karein
                        sudo docker pull ${DOCKER_IMAGE}:latest
                        
                        # Purane container ko forcefully remove karein taake conflict na ho
                        sudo docker rm -f django-app || true
                        
                        # Naya container volume mount aur correct port ke sath run karein
                        sudo docker run -d \\
                            --name django-app \\
                            -p 80:8000 \\
                            -v /home/ubuntu/media:/app/media \\
                            ${DOCKER_IMAGE}:latest
                    "
                    """
                }
            }
        }
    }
}