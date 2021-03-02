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
		buildDiscarder(logRotator(daysToKeepStr:'10', numToKeepStr: '10'))
		disableConcurrentBuilds()
	}
	stages{
		stage('Checkout'){
			steps{
				script{
					scmVars = checkout scm
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
					snapshotRepo:'demoArtifactory',
					releaseRepo:'demoArtifactory'
				)
				rtMavenRun(
					pom:'pom.xml',
					goals:'clean install',
					deployerId: 'deployer'
				)
				rtPublishBuildInfo(
					serverId:'demoArtifactory'
				)
			}
		}
		stage('Build Image'){
			steps{
				script{
					if(scmVars.GIT_BRANCH == 'origin/dev'){
						bat 'docker build --network=host --no-cache -t heenamittal11/demo-application:%BUILD_NUMBER% -f Dockerfile .'
					}
					else if(scmVars.GIT_BRANCH == 'origin/prod-new'){
						bat 'docker build --network=host --no-cache -t heenamittal11/demo-application-prod:%BUILD_NUMBER% -f Dockerfile .'
					}
				}
			}
		}
		stage('Push to DTR'){
			steps{
				script{
					bat 'docker login -u heenamittal11 -p Docker@11'
					if(scmVars.GIT_BRANCH == 'origin/dev'){
						bat 'docker push heenamittal11/demo-application:%BUILD_NUMBER%'
					}
					else if(scmVars.GIT_BRANCH == 'origin/prod-new'){
						bat 'docker push heenamittal11/demo-application-prod:%BUILD_NUMBER%'
					}
				}
			}
		}
		stage('Stop Running Container'){
			steps{
				script{
					if(scmVars.GIT_BRANCH == 'origin/dev'){
						tagname='demo-application'
					}
					else if(scmVars.GIT_BRANCH == 'origin/prod-new'){
						tagname='demo-application-prod'
					}
					bat '''
					for /f %%i in 'docker ps -aqf "name=^${tagname}"' do set containerId = %%i
					    If "%containerId%" == "" (
					    	echo "no Running Container"
					    )
					    else(
					    	docker stop %containerId%
						docker rm -f %containerId%
					    )
					     
			                '''
				}
			}
		}
		stage("Docker Deployment"){
			steps{
				script{
					if(scmVars.GIT_BRANCH == 'origin/dev'){
						bat 'docker run -it --name demo-application -d -p 6200:8080 heenamittal11/demo-application:%BUILD_NUMBER%'
					}
					else if(scmVars.GIT_BRANCH == 'origin/prod-new'){
						bat 'docker run -it --name demo-application-prod -d -p 6300:8080 heenamittal11/demo-application-prod:%BUILD_NUMBER%'
					}
				}
			}
		}
	}
	post{
		always{
			junit 'target/surefire-reports/*.xml'
		
		}
		success{
			mail body:"<br>JOB_NAME: ${env.JOB_NAME}<br>BUILD_NUMBER: ${env.BUILD_NUMBER}<br> BUILD_URL: ${env.BUILD_URL}",
			     mimeType:"text/html",
			     charset:"UTF-8",
			     subject: "SUCCESS --> ${env.JOB_NAME}",
			     to:"heena.mittal@nagarro.com"
		}
		failure{
			mail body:"<br>JOB_NAME: ${env.JOB_NAME}<br>BUILD_NUMBER: ${env.BUILD_NUMBER}<br> BUILD_URL: ${env.BUILD_URL}",
			     mimeType:"text/html",
			     charset:"UTF-8",
			     subject: "Failure --> ${env.JOB_NAME}",
			     to:"heena.mittal@nagarro.com"
		}
	}
}
