//
// 🦠 Corona-Warn-App
//

import Foundation

enum LastSubmissionFlowScreen: Int, Codable {

	case unknown = 1
	case testResult = 2
	case warnOthers = 3
	case symptoms = 4
	case symptomsOnset = 5

	// MARK: - Init

	init(from lastSubmissionFlowScreen: LastSubmissionFlowScreen) {
		switch lastSubmissionFlowScreen {
		case .unknown:
			self = .unknown
		case .testResult:
			self = .testResult
		case .warnOthers:
			self = .warnOthers
		case .symptoms:
			self = .symptoms
		case .symptomsOnset:
			self = .symptomsOnset
		}
	}

}
