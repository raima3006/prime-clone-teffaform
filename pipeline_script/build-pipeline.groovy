pipeline 
{
    agent any

    tools
    {
        jdk 'JDK'  
        nodejs 'NodeJS'
    }

    environment
    {
        SCANNER_HOME = tool 'SonarQube Scanner'
    }
    
    parameters
    {
        string (name: 'ECR_REPO_NAME' , defaultValue: 'amazon-prime', description: 'Enter your ECR Repository name')
        string (name: 'AWS_ACCOUNT_ID' , defaultValue: '654654152007', description: 'Enter your AWS Account Id')
    }

    stages 
    {
        stage('1. Git Checkout') 
        {
            steps 
            {
                git branch: 'main', url: 'https://github.com/raima3006/prime-clone-teffaform.git'
            }
        }
        
        stage('2. Sonarqube Analysis') 
        {
            steps 
            {
                withSonarQubeEnv('sonar-server')
                {
                    sh"""
                        ${SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=amazon-prime \
                        -Dsonar.projectName=amazon-prime \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://13.201.42.132:9000 \
                        -Dsonar.login=$SONAR_TOKEN
                    """
                }
            }
        }

        stage('3. Sonarqube Quality Gate') 
        {
            steps 
            {
                waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
            }
        }

        stage('4. NPM Install') 
        {
            steps 
            {
                sh "npm install"
            }
        }

        stage('5. Trivy Scan') 
        {
            steps 
            {
                sh "trivy fs . > trivy-scan-results.txt"
            }
        }

        stage('6. Docker Image Build') 
        {
            steps 
            {
                sh "docker build -t ${params.ECR_REPO_NAME} ."
            }
        }

        stage('7. Create ECR Repo') 
        {
            steps 
            {
                withCredentials([string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY'), 
                string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_KEY')]) 
                {
                    sh"""   
                        echo "DEBUG: AWS_ACCESS_KEY is set to: $AWS_ACCESS_KEY"
                        echo "DEBUG: AWS_SECRET_KEY is set to: $AWS_SECRET_KEY" 
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY
                        aws configure set aws_secret_access_key $AWS_SECRET_KEY
                        aws ecr describe-repositories --repository-names ${params.ECR_REPO_NAME} --region ap-south-1 || \
                        aws ecr create-repository --repository-name ${params.ECR_REPO_NAME} --region ap-south-1
                    """
                }
            }
        }

        stage('8. Logging to ECR & tag image') 
        {
            steps 
            {
                withCredentials([string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY'), 
                string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_KEY')]) 
                {
                    sh """
                        echo "DEBUG: AWS_ACCESS_KEY is set to: $AWS_ACCESS_KEY"
                        aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${params.AWS_ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com         
                        docker tag ${params.ECR_REPO_NAME} ${params.AWS_ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/${params.ECR_REPO_NAME}:$BUILD_NUMBER
                        docker tag ${params.ECR_REPO_NAME} ${params.AWS_ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/${params.ECR_REPO_NAME}:latest
                    """
                }
            }
        }

        stage('9. Push in the image to ECR') 
        {
            steps 
            {
                withCredentials([string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY'), 
                string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_KEY')]) 
                {
                    sh """
                        docker push ${params.AWS_ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/${params.ECR_REPO_NAME}:$BUILD_NUMBER
                        docker push ${params.AWS_ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/${params.ECR_REPO_NAME}:latest
                    """
                }
            }
        }

        stage('10. Cleanup Images from Jenkins Server') 
        {
            steps 
            {
                sh"""
                    docker rmi ${params.AWS_ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/${params.ECR_REPO_NAME}:$BUILD_NUMBER
                    docker rmi ${params.AWS_ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/${params.ECR_REPO_NAME}:latest
                """
            }
        }
    }
}
    

