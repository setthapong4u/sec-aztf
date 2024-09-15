pipeline {

    agent any

    parameters {
        booleanParam(name: 'DESTROY_ENV', defaultValue: false, description: 'Set to true to enable destruction')
    }
    
    environment {
        ARM_CLIENT_ID = credentials('azure-sp-client-id')
        ARM_CLIENT_SECRET = credentials('azure-sp-client-secret')
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        ARM_TENANT_ID = credentials('azure-tenant-id')
        GITHUB_REPO = 'setthapong4u/sec-aztf'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/setthapong4u/aztf.git'
            }
        }

    stage('Code Scanning by Prisma') {
            steps {
                withCredentials([
                    string(credentialsId: 'PRISMA_ACCESS_KEY', variable: 'USER'), 
                    string(credentialsId: 'PRISMA_SECRET_KEY', variable: 'PASS'), 
                    string(credentialsId: 'API_JP_URL', variable: 'URL_API')
                ]) {
                    script {
                        docker.image('bridgecrew/checkov:latest').inside("--entrypoint='' -v ${WORKSPACE}:/workspace -u 0:0") {
                            sh 'echo scanning code'
                            sh 'checkov  -d /workspace  --use-enforcement-rules -o cli --bc-api-key "${USER}::${PASS}" --prisma-api-url "${URL_API}" --repo-id ${GITHUB_REPO}'
                        }
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                // Initialize Terraform
                sh 'terraform init'
            }
        }
        
        stage('Terraform Plan') {
            steps {
                // Terraform plan
                sh 'terraform plan -out=tfplan'
            }
        }
        
        stage('Terraform Apply') {
            steps {
                // Apply the Terraform changes
                sh 'terraform apply -auto-approve tfplan'
            }
        }
        
        stage('Confirm Before Destroy') {
            when {
                expression {
                    return params.DESTROY_ENV == true
                }
            }
            steps {
                script {
                    input message: 'Are you sure you want to destroy the infrastructure? This action is irreversible.', ok: 'Yes, Destroy'
                }
            }
        }
        
        stage('Terraform Destroy') {
            when {
                expression {
                    return params.DESTROY_ENV == true
                }
            }
            steps {
                // Destroy the infrastructure
                sh 'terraform destroy -auto-approve'
            }
        }
    }
    
    post {
        always {
            // Clean workspace
            cleanWs()
        }
    }
}