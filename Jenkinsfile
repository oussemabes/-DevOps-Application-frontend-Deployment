pipeline {
    agent any
    tools {
        nodejs 'nodejs-19'
    }

    environment {
        SERVER_ADDRESS = '3.64.215.215'
        SERVER_USERNAME = 'ec2-user'
        DOCKER_IMAGE_NAME = 'oussemabes/docker-image:1.0.0'
        PROJECT_NAME = 'client'
        REPO_SERVER = '739761511001.dkr.ecr.eu-central-1.amazonaws.com'
        ECR_REGISTRY = '739761511001.dkr.ecr.eu-central-1.amazonaws.com/ecr-besbes'
        AWS_REGION = 'eu-central-1'
    }
    stages {
        stage('increment version') {
            steps {
                script {
                    echo 'incrementing app version...'
                    sh 'npm version patch --no-git-tag-version --allow-same-version'
                    def version = sh(returnStdout: true, script: 'npm version')
                    def versionProps = readJSON text: version
                    env.IMAGE_TAG = "${versionProps[env.PROJECT_NAME]}-${BUILD_NUMBER}"
                }
            }
        }
        stage('Push Image') {
            steps {
                script {
                    
                        sh 'docker build -t ${ECR_REGISTRY}:${IMAGE_TAG} .'
                        // Push the image to Amazon ECR
                        withCredentials([usernamePassword(credentialsId: 'ecr-credentials', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                            sh "echo $PASS | docker login --username $USER --password-stdin ${REPO_SERVER}"
                            sh "docker push ${ECR_REGISTRY}:${IMAGE_TAG}"
                        
                     }
                }
            }
        }
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                script {
                        def shellCmd = "bash ./server-cmds-react.sh ${DOCKER_IMAGE_NAME} ${IMAGE_TAG}"
                        sshagent(['ec2-client-key']) {
                            sh "scp -o StrictHostKeyChecking=no server-cmds-react.sh ${SERVER_USERNAME}@${SERVER_ADDRESS}:/home/${SERVER_USERNAME}"
                            sh "scp -o StrictHostKeyChecking=no docker-compose-react.yml ${SERVER_USERNAME}@${SERVER_ADDRESS}:/home/${SERVER_USERNAME}"
                            sh "ssh -o StrictHostKeyChecking=no ${SERVER_USERNAME}@${SERVER_ADDRESS} ${shellCmd}"
                        }
                    } 
                }
        }
        stage('commit version update') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'githubpat', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        // git config here for the first time run
                        sh 'git config --global user.email "mahdijenkins@jenkins.com"'
                        sh 'git config --global user.name "mahdijenkins"'
                        sh "git remote set-url origin https://${USER}:${PASS}@github.com/Mahdiboudaouara/besbesClient.git"
                        sh 'git add .'
                        sh 'git commit -m "ci: version bump"'
                        sh "git push origin HEAD:${BRANCH_NAME}"
                    }
                }
            }
        }
    }
    post {
        always {
            sh 'rm -rf node_modules' // Clean up after build
        }
    }
}
