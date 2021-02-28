def scmVars
pipeline{
	agent any
    tools{
	 maven 'Maven3'
	}
	options{
	timestamps()
	timeout(time: 1, unit: 'HOURS')
	skipDefaultCheckout()
	buildDiscarder(logRotator(daysToKeepStr: '10', numToKeepStr:'10'))
	disableConcurrentBuilds()
	}
	stages{
		 stage('Checkout'){
			steps{
				script{
					scmVars = checkout scm
					echo scmVars.GIT_BRANCH
				}
		    }
		 }
		 stage('build'){
			steps{
				echo 'build in ${scmVars.GIT_BRANCH} branch'
				bat "mvn install"
			}
		 }
		 stage('Unit Testing'){
			steps{
				echo 'Unit testing in ${scmVars.GIT_BRANCH} branch'
				bat "mvn test"
			}
		 }
		 stage('Sonar Analysis'){
			steps{
				withSonarQubeEnv("Test_Sonar"){
					bat "mvn sonar:sonar"
				}
			}
		 }
		 stage('Upload to artifactory'){
			steps{
				rtMavenDeployer(
					id:'deployer',
					serverId: 'demoArtifactory',
					releaseRepo: 'demoArtifactory',
					snapshotRepo: 'dempArtifactory'
				)
				rtMavenRun(
					pom: 'pom.xml',
					goals: 'clean install',
					deployerId: 'deployer'
				)
				rtPublishBuildInfo(
					serverId: 'demoArtifactory'
				)
			}
		 }
		 stage('Docker Image'){
			steps{
				bat 'docker build --network=host --no-cache -t heenamittal11/demo-application:%BUILD_NUMBER% -f Dockerfile .'
			}
		 }
		 
		 stage('Push to DTR'){
			steps{
				bat 'docker login -u heenamittal11 -p Docker@11'
				bat 'docker push heenamittal11/demo-application:%BUILD_NUMBER%'
			}
		 }
		 
		 stage('Stop running Container'){
			steps{
				bat '''
					for /f %%i in ('docker ps -aqf "name=^demo-application"') do set containerId=%%i
				    echo %containerId%
					if "%containerId%" == ""(
						echo "No Container Running"
					)else (
					  docker stop %containerId%
					  docker rm -f %containerId%
					)
				'''
			}
		 }
		 stage('Docker Deployment'){
			steps{
				bat 'docker run -it --name demo-application -d -p 6200:8080 heenamittal11/demo-application:%BUILD_NUMBER%'
			}
		 }
	}
		 post{
		  always{
		    junit 'target/surefire-reports/*.xml'
		  }
		 
	}
}
