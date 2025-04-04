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
        PROJECT_DIR = 'projectbyme/amazon-prime-clone'
        APP_REPO = 'https://github.com/icyflame21/Amazon-Prime-Clone.git'
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
                deleteDir()  // This ensures a fresh start
                git branch: 'main', url: 'https://github.com/raima3006/prime-clone-teffaform.git'
                sh """
                    git clone ${env.APP_REPO} ${env.PROJECT_DIR}
                """
                sh 'ls -la'  // Debugging step
            }
        }
       
        stage('2. Sonarqube Analysis') 
        {
            steps 
            {
                withSonarQubeEnv('sonar-server') 
                {
                    sh """
                        $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectKey=amazon-prime \
                        -Dsonar.projectName=amazon-prime \
                        -Dsonar.sources=${env.PROJECT_DIR} \
                        -Dsonar.host.url=http://65.0.85.21:9000 \
                        -Dsonar.login=squ_8855ff3d32a4a6c2d206571eb1b67cf800cf4cf7 \
                        -Dsonar.javascript.lcov.reportPaths=${env.PROJECT_DIR}/coverage/lcov.info \
                        -Dsonar.coverage.exclusions=**/test/**,**/node_modules/**
                    """
                }
            }
        }

        stage('3. Sonarqube Quality Gate') 
        {
            steps 
            {
                waitForQualityGate abortPipeline: true, credentialsId: 'sonar-token'
            }
        }

        stage('4. NPM Install') 
        {
            steps 
            {
                dir(env.PROJECT_DIR) 
                {
                    sh "npm install --legacy-peer-deps"
                }
            }
        }

        stage('5. Trivy Scan') 
        {
            steps 
            {
                dir(env.PROJECT_DIR) 
                {
                    sh "trivy fs --security-checks vuln,config . > trivy-scan-results.txt"
                }
            }
        }

        stage('6. Docker Image Build') 
        {
            steps 
            {
                sh"""
                    cp Dockerfile ${WORKSPACE}/${env.PROJECT_DIR}/
                    cd ${WORKSPACE}/${env.PROJECT_DIR} && \
                    docker build \
                        -t ${params.ECR_REPO_NAME} \
                        --build-arg BUILD_NUMBER=${BUILD_NUMBER} \
                        -f Dockerfile .
                """
            }
        }

        stage('7. Create ECR Repo') 
        {
            steps 
            {
                withCredentials([string(credentialsId: 'access-key', variable: 'AWS_ACCESS_KEY'), 
                string(credentialsId: 'secret-key', variable: 'AWS_SECRET_KEY'),
                string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN'),]) 
                {
                    sh"""
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
                withCredentials([string(credentialsId: 'access-key', variable: 'AWS_ACCESS_KEY'), 
                string(credentialsId: 'secret-key', variable: 'AWS_SECRET_KEY')]) 
                {
                    sh"""
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
                withCredentials([string(credentialsId: 'access-key', variable: 'AWS_ACCESS_KEY'), 
                string(credentialsId: 'secret-key', variable: 'AWS_SECRET_KEY')]) 
                {
                    sh"""
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