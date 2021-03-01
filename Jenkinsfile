def scmVars
pipeline{
	agent:any
	tools:{
		maven:'Maven3'
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
			       
	}
}
