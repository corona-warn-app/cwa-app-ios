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
	case create(RiskExposureMetadata)
	case updateRiskExposureMetadata(ENFRiskCalculationResult)
}

enum PPATestResultMetadata {
	case registerNewTestMetadata(Date, String, CoronaTestType)
	case updateTestResult(TestResult, String, CoronaTestType)
}

enum PPAKeySubmissionMetadata {
	case create(KeySubmissionMetadata, CoronaTestType)
	case submitted(Bool, CoronaTestType)
	case submittedInBackground(Bool, CoronaTestType)
	case submittedAfterCancel(Bool, CoronaTestType)
	case submittedAfterSymptomFlow(Bool, CoronaTestType)
	case submittedWithTeletan(Bool, CoronaTestType)
	case lastSubmissionFlowScreen(LastSubmissionFlowScreen?, CoronaTestType)
	case advancedConsentGiven(Bool, CoronaTestType)
	case setHoursSinceTestResult(CoronaTestType)
	case setHoursSinceTestRegistration(CoronaTestType)
	case setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration(CoronaTestType)
	case setHoursSinceHighRiskWarningAtTestRegistration(CoronaTestType)
}

enum PPAExposureWindowsMetadata {
	case collectExposureWindows([RiskCalculationExposureWindow])
}

enum PPASubmissionMetadata {
	case lastAppReset(Date)
}
