def scmVars
pipeline{
	agent any
	tools{
		maven 'Maven3'
	}
	options{
		timestamps()
		timeout(time: 1, unit:'HOURS')
		skipDefaultCheckout()
		buildDiscarder(logRotator(daysToKeepStr:'10',numToKeepStr:'10'))
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
				script{
					echo "build in "  + scmVars.GIT_BRANCH
					bat "mvn install"
				}
			}
		}
		stage('Unit Testing'){
			steps{
				script{
					bat "mvn test"
				}
			}
		}
		stage('SonarQube Analysis'){
			steps{
				script{
					withSonarQubeEnv("Test_Sonar"){
						bat "mvn sonar:sonar"
					}
				}
			}
		}
		stage('Upload to Artifactory'){
			steps{
				rtMavenDeployer{
					id:'deployer'
					serverId:'demoArtifactory'
					releaseRepo:'demoArtifactory'
					snapshotRepo:'demoArtifactory'
				}
				rtMavenRun{
					pom:'pom.xml'
					goals:'clean install'
					deployerId:'deployer'
				}
				rtPublishBuildInfo{
					serverId:'demoArtifactory'
				}
			}
		}
	}
}
