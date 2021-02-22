//
// 🦠 Corona-Warn-App
//

import Foundation

enum LastSubmissionFlowScreen: Int, Codable {

	case submissionFlowScreenUnknown = 0
	case submissionFlowScreenOther = 1
	case submissionFlowScreenTestResult = 2
	case submissionFlowScreenWarnOthers = 3
	case submissionFlowScreenSymptoms = 4
	case submissionFlowScreenSymptomOnset = 5
	
	// MARK: - Init

	init(from lastSubmissionFlowScreen: LastSubmissionFlowScreen) {
		switch lastSubmissionFlowScreen {
		case .submissionFlowScreenUnknown:
			self = .submissionFlowScreenUnknown
		case .submissionFlowScreenOther:
			self = .submissionFlowScreenOther
		case .submissionFlowScreenTestResult:
			self = .submissionFlowScreenTestResult
		case .submissionFlowScreenWarnOthers:
			self = .submissionFlowScreenWarnOthers
		case .submissionFlowScreenSymptoms:
			self = .submissionFlowScreenSymptoms
		case .submissionFlowScreenSymptomOnset:
			self = .submissionFlowScreenSymptomOnset
		}
	}

	var protobuf: SAP_Internal_Ppdd_PPALastSubmissionFlowScreen {
		switch self {
		case .submissionFlowScreenUnknown:
			return .submissionFlowScreenUnknown
		case .submissionFlowScreenOther:
			return .submissionFlowScreenOther
		case .submissionFlowScreenTestResult:
			return .submissionFlowScreenTestResult
		case .submissionFlowScreenWarnOthers:
			return .submissionFlowScreenWarnOthers
		case .submissionFlowScreenSymptoms:
			return .submissionFlowScreenSymptoms
		case .submissionFlowScreenSymptomOnset:
			return .submissionFlowScreenSymptomOnset
		}
	}
}
