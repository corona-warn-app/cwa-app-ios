//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import Foundation

enum RiskLevel: Int, Codable {

	case low = 1
	case high = 2

	// MARK: - Init

	init(from riskLevel: SAP_Internal_V2_NormalizedTimeToRiskLevelMapping.RiskLevel) {
		switch riskLevel {
		case .low:
			self = .low
		case .high:
			self = .high
		default:
			fatalError("Only low and high risk levels are supported")
		}
	}

	var protobuf: SAP_Internal_Ppdd_PPARiskLevel {
		switch self {
		case .low:
			return .riskLevelLow
		case .high:
			return .riskLevelHigh
		}
	}
}
