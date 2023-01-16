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

    stage('deploy')
    {
        steps {
            echo "start deploy"
            sh 'ls -al'
            sh 'touch deploy.sh'
            sh 'touch switch.sh'
            sh './deploy.sh'
        }
    }
  }
}