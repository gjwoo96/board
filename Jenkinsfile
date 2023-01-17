pipeline {
  agent any

  tools {
    maven 'M3'
  }

  stages {
    stage('parameter check')
    {
    	steps
    	{
    		echo "Current workspace : ${workspace}"
    		sh 'mvn -version'
    	}
    }

    stage('build')
    {
        steps {
            sh 'pwd'
            sh 'mvn -f pom.xml clean install -P release'
            archive '**/target/*.war'
        }
    }

    stage('deploy to board')
    {
        steps {
            echo "start deploy"
            echo "connect jira deploy"
            sh 'chmod 755 deploy.sh'
            sh './deploy.sh'
        }
    }
  }
}