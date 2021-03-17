////
// 🦠 Corona-Warn-App
//

import Foundation

// This enums give the access to all analytics data to log. So if you want to log new data or just particial data of an existing one, add the case here and implement the case in the Analytics.

enum PPADataType {
	case userData(PPAUserMetadata)
	case riskExposureMetadata(PPARiskExposureMetadata)
	case clientMetadata(PPAClientMetadata)
	case testResultMetadata(PPATestResultMetadata)
	case keySubmissionMetadata(PPAKeySubmissionMetadata)
	case exposureWindowsMetadata(PPAExposureWindowsMetadata)
	case submissionMetadata(PPASubmissionMetadata)
	
	var description: String {
		switch self {
		case .userData:
			return "userData"
		case .riskExposureMetadata:
			return "riskExposureMetadata"
		case .clientMetadata:
			return "clientMetadata"
		case .testResultMetadata:
			return "testResultMetadata"
		case .keySubmissionMetadata:
			return "keySubmissionMetadata"
		case .exposureWindowsMetadata:
			return "exposureWindowsMetadata"
		case .submissionMetadata:
			return "submissionMetadata"
		}
	}
}

enum PPAUserMetadata {
	case create(UserMetadata?)
}

enum PPARiskExposureMetadata {
	case create(RiskExposureMetadata)
	case updateRiskExposureMetadata(RiskCalculationResult)
}

enum PPAClientMetadata {
	case create(ClientMetadata)
	case setClientMetaData
}

enum PPATestResultMetadata {
	case create(TestResultMetadata)
	case testResult(TestResult)
	case testResultHoursSinceTestRegistration(Int?)
	case updateTestResult(TestResult, String)
	case registerNewTestMetadata(Date, String)
}

enum PPAKeySubmissionMetadata {
	case create(KeySubmissionMetadata)
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
	case updateSubmittedWithTeletan
	case setHoursSinceTestResult
	case setHoursSinceTestRegistration
	case setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration
	case setHoursSinceHighRiskWarningAtTestRegistration
}

enum PPAExposureWindowsMetadata {
	case collectExposureWindows([RiskCalculationExposureWindow])
}

enum PPASubmissionMetadata {
	case lastAppReset(Date)
}
