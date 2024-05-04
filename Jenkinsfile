pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-key-user')
        AWS_SECRET_ACCESS_KEY = credentials('aws-key-pass')
        AWS_DEFAULT_REGION = "us-east-1"
    }

    stages {
        stage('SCM Init ...') {
            steps {
                git branch: 'main', url: 'https://github.com/MorelSami/Online-Retail-Eks-Project.git'
            }
        }
        
        stage ("Terraform  code syntax check ...") {
            steps {
                sh "terraform fmt" 
            }
        }
        
        stage ("Terraform initialization ...") {
            steps {
                sh "terraform init" 
            }
        }
        
        stage ("Terraform validation ...") {
            steps {
                sh "terraform validate" 
            }
        }
  
        stage ("Terraform preview ...") {
            steps {
                sh "terraform plan" 
            }
        }
        stage ("Resource provisioning based on selected action > ") {
            steps {
                sh 'terraform ${action} --auto-approve' 
           }
        }
        stage("Deploy to EKS") {
            when {
               expression { params.apply }
            }
            steps {
                  sh "aws eks update-kubeconfig --name eks_cluster"
                   sh "kubectl apply -f deployment.yaml"
             }
        }
        stage ("Provisioning complete") {
            steps {
                sh 'echo "Online retail store application successfully deployed."' 
           }
        }
    }
}