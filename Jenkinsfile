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
		buildDiscarder(logRotator(daysToKeepStr: '10', numToKeepStr: '10'))
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
		stage('Build'){
			steps{
				bat "mvn install"
			}
		}
		stage('Unit Testing'){
			steps{
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
		stage('Upload to Artifactory'){
			steps{
				rtMavenDeployer(
					id:'deployer',
					serverId:'demoArtifactory',
					releaseRepo:'demoArtifactory',
					snapshotRepo:'demoArtifactory'
				)
				rtMavenRun(
					pom: 'pom.xml',
					goals: 'clean install'
					deployerId: 'deployer'
				)
				rtPublishBuildInfo(
					serverId:'demoArtifactory'
				)
			}
		}
		stage('Build Docker Image'){
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
		
	}
}
