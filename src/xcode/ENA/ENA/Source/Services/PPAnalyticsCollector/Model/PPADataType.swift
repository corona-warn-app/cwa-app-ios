////
// 🦠 Corona-Warn-App
//

import Foundation

enum PPADataType {
	case userData(PPAUserMetadata)
	case riskExposureMetadata(PPARiskExposureMetadata)
	case clientMetadata(PPAClientMetadata)
	case testResultMetadata(PPATestResultMetadata)
	case keySubmissionMetadata(PPAKeySubmissionMetadata)
}

enum PPAUserMetadata {
	case complete(UserMetadata)
}

enum PPARiskExposureMetadata {
	case complete(RiskExposureMetadata)
}

enum PPAClientMetadata {
	case complete(ClientMetadata)
	case eTag(String?)
}

enum PPATestResultMetadata {
	case complete(TestResultMetaData)
	case testResult(TestResult)
	case testResultHoursSinceTestRegistration(Int?)
	case updateTestResult(TestResult)
}

enum PPAKeySubmissionMetadata {
	case complete(KeySubmissionMetadata)
	case submitted(Bool)
	case submittedInBackground(Bool)
	case submittedAfterCancel(Bool)
	case submittedAfterSymptomFlow(Bool)
	case submittedWithTeletan(Bool)
	case lastSubmissionFlowScreen(LastSubmissionFlowScreen?)
	case advancedConsentGiven(Bool)
	case hoursSinceTestResult(Int32)
	case keySubmissionHoursSinceTestRegistration(Int32?)
	case daysSinceMostRecentDateAtRiskLevelAtTestRegistration(Int32)
	case hoursSinceHighRiskWarningAtTestRegistration(Int32)
	case setHoursSinceTestResult
	case setHoursSinceTestRegistration
	case setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration
	case setHoursSinceHighRiskWarningAtTestRegistration
}
