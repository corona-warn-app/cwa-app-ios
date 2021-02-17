//
// 🦠 Corona-Warn-App
//

import Foundation

enum TestResult: Int, CaseIterable, Codable {
	case pending = 0
	case negative = 1
	case positive = 2
	case invalid = 3
	case expired = 4
	
	#if !canImport(XCTest) // only for the 'real' app, not the tests
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
	#endif
}
