//
// 🦠 Corona-Warn-App
//

import Foundation

struct NormalizedTimeToRiskLevelMapping: Codable {

	// MARK: - Init

	init(from normalizedTimeToRiskLevelMapping: SAP_Internal_V2_NormalizedTimeToRiskLevelMapping) {
		self.normalizedTimeRange = ENARange(from: normalizedTimeToRiskLevelMapping.normalizedTimeRange)
		self.riskLevel = RiskLevel(from: normalizedTimeToRiskLevelMapping.riskLevel)
	}

	// MARK: - Internal
	
	let normalizedTimeRange: ENARange
	let riskLevel: RiskLevel
	
}
