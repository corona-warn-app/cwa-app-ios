////
// 🦠 Corona-Warn-App
//

import Foundation

// This enums give the access to all analytics data to log. So if you want to log new data or just particial data of an existing one, add the case here and implement the case in the Analytics.

enum PPADataType {
	case userData(PPAUserMetadata)
	case riskExposureMetadata(PPARiskExposureMetadata)
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
	case update
}

enum PPATestResultMetadata {
	case create(TestResultMetadata)
	case testResult(TestResult)
	case testResultHoursSinceTestRegistration(Int?)
	case updateTestResult(TestResult, String)
	case registerNewTestMetadata(Date, String)
	case dateOfConversionToENFHighRisk(Date)
}

enum PPAKeySubmissionMetadata {
	case create(KeySubmissionMetadata)
	case submitted(Bool)
	case submittedInBackground(Bool)
	case submittedAfterCancel(Bool)
	case submittedAfterSymptomFlow(Bool)
	case submittedWithTeletan(Bool)
	case submittedWithCheckins(Bool?)
	case lastSubmissionFlowScreen(LastSubmissionFlowScreen?)
	case advancedConsentGiven(Bool)
	case hoursSinceTestResult(Int32)
	case keySubmissionHoursSinceTestRegistration(Int32?)
	case daysSinceMostRecentDateAtRiskLevelAtTestRegistration(Int32)
	case hoursSinceHighRiskWarningAtTestRegistration(Int32)
	case updateSubmittedWithTeletan
	case setHoursSinceTestResult
	case setHoursSinceTestRegistration
	case setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration
	case setHoursSinceENFHighRiskWarningAtTestRegistration
	case setDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration
	case setHoursSinceCheckinHighRiskWarningAtTestRegistration
}

enum PPAExposureWindowsMetadata {
	case collectExposureWindows([RiskCalculationExposureWindow])
}

enum PPASubmissionMetadata {
	case lastAppReset(Date)
}
