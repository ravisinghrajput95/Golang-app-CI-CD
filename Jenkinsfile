pipeline {
    agent any
    tools {
        go 'Go'
    }
    environment {
        GO114MODULE = 'on'
        CGO_ENABLED = 0 
        GOPATH = "${JENKINS_HOME}"

        DOCKER_TAG = getVersion()
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
                     sh 'go get -u golang.org/x/lint/golint'
                     sh 'go run hello.go'
                     sh 'go get github.com/mattn/go-isatty@v0.0.12'
             
                 }          
            }
        }

        stage('Test') {
            steps {
                withEnv(["PATH+GO=${GOPATH}/bin"]){
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
                sh 'docker build -t rajputmarch2020/go_app:${DOCKER_TAG} .'
            }
        }

        stage('Scan image'){
            steps{
                sh 'trivy image rajputmarch2020/go_app:${DOCKER_TAG}'
            }
        }

        stage('Docker push'){
            steps{
                withCredentials([string(credentialsId: 'dockerhub', variable: 'password')]){
                    sh 'docker login -u rajputmarch2020 -p ${password} '
                }
                    sh 'docker push rajputmarch2020/go_app:${DOCKER_TAG}'
                }
            }
     
        }
        
    post {
		always {
			mail bcc: '', body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "${currentBuild.result} CI: Project name -> ${env.JOB_NAME}", to: "ravisinghrajput005@gmail.com";            
		}
        success{
            echo 'Pipeline executed Sucessfully'
        }
        failure{
            echo 'Pipeline failed'
        }
        cleanup{
            cleanWs deleteDirs: true, patterns: [[pattern: 'node_modules', type: 'EXCLUDE']]
        }
	}
}
   def getVersion(){
      def commitHash =  sh returnStdout: true, script: 'git rev-parse --short HEAD'
      return commitHash
}
