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
            sh 'mvn -f board/pom.xml clean install -P release'
            archive '**/target/*.war'
        }
     }
  }
}