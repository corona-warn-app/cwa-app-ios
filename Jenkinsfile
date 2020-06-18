#!/usr/bin/env groovy
@Library(['piper-lib', 'piper-lib-os', 'mobile-pipeline-lib']) _

try {
	if (env.BRANCH_NAME == 'master') {
	   // Central Build
		node {
			lock(resource: "${env.JOB_NAME}/10", inversePrecedence: true) {
				milestone 10
 			   	stage('Checkout Source Code') {
 				   deleteDir()
 				   checkout scm

 				   setupPipelineEnvironment script: this, storeGithubStatistics: true
 			   	}
			}
			final def stagingInfo
		   	lock(resource: "${env.JOB_NAME}/20", inversePrecedence: true) {
			   milestone 20
			   stage('Central Build') {
				   measureDuration(script: this, measurementName: 'build_duration') {
					   stashFiles(script: this) {
						   forcePushToNaasForkMasterBranch()
						   def xMakeCredentialsId = globalPipelineEnvironment.configuration.general.xMakeCredentialsId
						   stagingInfo = triggerRemoteXMakeJob(xMakeCredentialsId, 'naas-mobile/naas-mobile-cwa-app-ios-internal-SP-REL-common_indirectshipment')
					   }
				   }
			   }
			}
			lock(resource: "${env.JOB_NAME}/30", inversePrecedence: true) {
				milestone 30
				stage('Checkmarx Security Scan') {
					executeCheckmarxScan script: this
				}
			}
			lock(resource: "${env.JOB_NAME}/40", inversePrecedence: true) {
				milestone 40
				stage('BlackDuck Open Source Scan') {
				   println("StagingInfo repo: ${stagingInfo.stagingRepoURL}")
				   println("StagingInfo version: ${stagingInfo.projectVersion}")
 				   def nexusFetchUrl = stagingInfo.stagingRepoURL + "/com/sap/de/rki/coronawarnapp/ios/Corona-Warn-App_release/" + stagingInfo.projectVersion + "/Corona-Warn-App_release-" + stagingInfo.projectVersion + "-Release.ipa"
				   executeProtecodeScan script: this, fetchUrl : nexusFetchUrl
			  	}
			}
			lock(resource: "${env.JOB_NAME}/50", inversePrecedence: true) {
				milestone 50
				stage('WhiteSource Scan') {
					executeWhitesourceScan script: this, scanType: 'unifiedAgent'
			  	}
			}
		}
	}
} catch (Throwable err) { // catch all exceptions
	globalPipelineEnvironment.addError(this, err)
	throw err
} finally {
	node {
		influxWriteData(script: this, artifactVersion: '0.0.1')
		mailSendNotification script: this
	}
}
def forcePushToNaasForkMasterBranch() {
    def config = globalPipelineEnvironment.configuration.general
    def gitSSHCredentialsId = config.gitSshKeyCredentialsId
    def gitSshUrl = "git@github.wdf.sap.corp:NAAS-Mobile/cwa-app-ios-internal.git"
    println("Push master to Naas-Fork repo ${gitSshUrl}.")
    sshagent([gitSSHCredentialsId]) {
        sh """
	    git remote add naas ${gitSshUrl}
            git push -f naas HEAD:master
	    git remote remove naas
        """
    }
}
def triggerRemoteXMakeJob(String xMakeCredentialsId, String xMakeJobName) {
	def xMakeJobUrl = getXmakeJobUrl(xMakeJobName)
	def xMakeJobParameters = 'MODE=stage\nTREEISH=master'
	println("triggerXMakeMobileBuild with parameters: xMakeCredentialsId: ${xMakeCredentialsId}, xMakeJobUrl: ${xMakeJobUrl}, xMakeJobParameters: ${xMakeJobParameters}")

  	def buildResult = triggerRemoteJob (
		auth: CredentialsAuth(credentials: xMakeCredentialsId),
		job: xMakeJobUrl,
		parameters: xMakeJobParameters
  	)

	if(buildResult.getBuildResult() == Result.UNSTABLE) {
		error("ERROR! Remote xMake build unstable, therefor failing pipeline! Check xMake job for root cause. " + buildResult.getBuildUrl())
	}

	//Download and parse the archived "build-results.json" (if generated and archived by remote build)
	def buildResultsJson = buildResult.readJsonFileFromBuildArchive('build-results.json')
	return [stagingRepoURL:buildResultsJson.stage_repourl, projectVersion:buildResultsJson.project_version]
}

def getXmakeJobUrl(String xMakeJobName) {
    println("Searching for xMakeJob with name: ${xMakeJobName}.")

	def xMakeJobFinderPluginUrl = 'https://xmake-nova.wdf.sap.corp/job_finder/api/xml?input='

	def response = httpRequest xMakeJobFinderPluginUrl+xMakeJobName
	if(response.status.equals(200)) {
		def rootNode = new XmlParser().parseText(response.content)
		def jobNode = rootNode.children()[0]
		for(child in jobNode) {
			if(child.name().equals("url")) {
				return child.text()
			}
		}
	}
    error("Error, xMakeJob with name ${xMakeJobName} could not be found!")
}
