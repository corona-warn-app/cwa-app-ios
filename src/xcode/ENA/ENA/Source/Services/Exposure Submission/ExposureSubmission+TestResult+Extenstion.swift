////
// 🦠 Corona-Warn-App
//

import Foundation
extension TestResult {
	var protobuf: SAP_Internal_Ppdd_PPATestResult? {
		switch self {
		case .pending:
			return .testResultPending
		case .negative:
			return .testResultNegative
		case .positive:
			return .testResultPositive
		case .expired, .invalid:
			return nil
		}
	}
}
