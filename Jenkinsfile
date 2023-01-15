pipeline {
  agent any
  stages {
    stage('Clone') {
        steps {
            echo 'Clone'
            git branch: 'main', credentialsId: 'nect2r-git', url: 'https://github.com/gjwoo96/board.git'
        }
    }
  }
}