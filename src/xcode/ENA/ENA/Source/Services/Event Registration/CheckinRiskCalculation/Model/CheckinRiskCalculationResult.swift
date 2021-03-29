////
// 🦠 Corona-Warn-App
//

extension SAP_Internal_V2_NormalizedTimeToRiskLevelMapping.RiskLevel: Codable {
	static func == (
		rhs: SAP_Internal_V2_NormalizedTimeToRiskLevelMapping.RiskLevel,
		lhs: RiskLevel) -> Bool {
		if rhs == SAP_Internal_V2_NormalizedTimeToRiskLevelMapping.RiskLevel.high && lhs == RiskLevel.high {
			return true
		} else if rhs == SAP_Internal_V2_NormalizedTimeToRiskLevelMapping.RiskLevel.low && lhs == RiskLevel.low {
			return true
		} else {
			return false
		}
	}
}

struct CheckinRiskCalculationResult: Codable {
	let checkinIdsWithRiskPerDate: [Date: [CheckinIdWithRisk]]
	let riskLevelPerDate: [Date: SAP_Internal_V2_NormalizedTimeToRiskLevelMapping.RiskLevel]

}

struct CheckinIdWithRisk: Codable {
	let checkinId: Int
	let riskLevel: SAP_Internal_V2_NormalizedTimeToRiskLevelMapping.RiskLevel
}

extension CheckinRiskCalculationResult {

	var riskLevel: RiskLevel {
		// The Total Risk Level is High if there is least one Date with Risk Level per Date calculated as High; it is Low otherwise.
		if riskLevelPerDate.contains(where: {
			$0.value == .high
		}) {
			return .high
		} else {
			return .low
		}
	}
}
