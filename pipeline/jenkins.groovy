pipeline {
    agent any
    parameters {
        choice(name: 'OS', choices: ['linux', 'darwin', 'windows'], description: 'Pick OS')
        choice(name: 'ARCH', choices: ['amd64', 'arm', 'arm64'], description: 'Pick architecture')
    }
    
    environment {
        REPO = 'https://github.com/sergeypashkov/kbot'
        BRANCH = 'main'
    }
    
    stages {
        
        stage('clone') {
            steps {
            echo "CLONE REPOSITORY"
                git branch: "${BRANCH}", url: "${REPO}"
            }
        }
        
        stage('test') {
            steps {
                echo "TEST EXECUTION STARTED"
                sh 'make test'
            }
        }
        
        stage('build') {
            steps {
                echo 'BUILD EXECUTION STARTED'
                sh "make ${params.OS} ${params.ARCH}"
            }
        }
        
        stage('image') {
            steps {
                echo 'BUILD IMAGE EXECUTION STARTED'
                sh "make image ${params.OS} ${params.ARCH}"
            }
        }
        
        stage('push') {
            steps {
                echo 'PUSH EXECUTION STARTED'
                sh 'make push'
            }
        }
    }
}
