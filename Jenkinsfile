pipeline {
    agent any
    tools {
        go 'Go'
    }
    environment {
        GO114MODULE = 'on'
        CGO_ENABLED = 0 
        GOPATH = "${JENKINS_HOME}"
        PROJECT_ID = "$PROJECT_ID"
        CLUSTER_NAME = "$CLUSTER_NAME"
        LOCATION = "$LOCATION"
        CREDENTIALS_ID = 'My First Project'
    }
    stages {
        stage('Git checkout'){
            steps{
                echo 'Codecheckout'
                git branch: 'main', credentialsId: 'github', url: 'https://github.com/ravisinghrajput95/Golang-app-CI-CD.git'
            }
        }

        stage('Initialize') {
            steps {
                echo '=============Initializing==================='
                 dir("src"){
                     sh 'go mod init simple-go/helloworld'
                     sh 'go mod tidy'
                     sh 'go get github.com/gin-gonic/gin'
                     sh 'go get github.com/gin-gonic/contrib/static'
                     sh 'go run hello.go'
                     
             
                 }          
            }
        }

        stage('Pre Test') {
            steps {
                echo 'Installing dependencies'
                dir('src'){
                    sh 'go version'
                    sh 'go get -u golang.org/x/lint/golint'
                    sh 'go get github.com/mattn/go-isatty@v0.0.12'
                }

            }
        }

        stage('Test') {
            steps {
                withEnv(["PATH+GO=${GOPATH}/go/bin"]){
                    dir('src'){
                    echo 'Running vetting'
                    sh 'go vet .'
                    echo 'Running linting'
                    sh 'golint . '
                    echo 'Formatting the code'
                    sh 'go fmt .'
                    }
                }
            }
        }

        stage('Docker build'){
            steps{
                sh "docker build -t . rajputmarch2020/go_app:${env.BUILD_ID}"
            }
        }

        stage('Scan image'){
            steps{
                sh "trivy image rajputmarch2020/go_app:${env.BUILD_ID}"
            }
        }

        stage('Docker push'){
            steps{
                withCredentials([string(credentialsId: 'dockerhub', variable: 'password')]){
                    sh 'docker login -u rajputmarch2020 -p ${password} '
                }
                    sh "docker push rajputmarch2020/go_app:${env.BUILD_ID}"
                }
            }

        stage('Approval'){
            steps{
                script{
                    timeout(10) {
                        mail bcc: '', body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> Go to build url and approve the deployment request <br> URL de build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "${currentBuild.result} CI: Project name -> ${env.JOB_NAME}", to: "ravisinghrajput005@gmail.com";  
                        input(id: "Deploy Gate", message: "Deploy ${params.project_name}?", ok: 'Deploy')
                    }
                }
            }
        }

        stage ("Deploy to GKE"){
            steps{
                sh "sed -i 's/go_app:latest/go_app:${env.BUILD_ID}/g' Deployment.yaml"
                step([$class: 'KubernetesEngineBuilder', 
                projectId: env.PROJECT_ID, 
                clusterName: env.CLUSTER_NAME, 
                location: env.LOCATION, 
                manifestPattern: 'Deployment.yaml', 
                credentialsId: env.CREDENTIALS_ID, 
                verifyDeployments: true])
            }
        }
    }
        
    post {
		always {
			mail bcc: '', body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "${currentBuild.result} CI: Project name -> ${env.JOB_NAME}", to: "ravisinghrajput005@gmail.com";            
		}
        success{
            echo 'Pipeline executed Sucessfully'
            slackSend color: "good", message: "Status: Pipeline executed successfully  | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "
        }
        failure{
            echo 'Pipeline failed'
            slackSend color: "danger", message: "Status: Build was failure  | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "
        }
        aborted{
            echo "Build was aborted"
            slackSend color: "yellow", message: "Build was aborted  | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "
        
        }
        unstable{
            echo "Build is unstable"
            slackSend color: "yellow", message: "Status: Pipeline executed successfully  | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "
        }
        cleanup{
            cleanWs deleteDirs: true, patterns: [[pattern: 'node_modules', type: 'EXCLUDE']]
        }
	}
}
