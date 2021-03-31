////
// 🦠 Corona-Warn-App
//

struct CheckinRiskCalculationResult: Codable {
	let calculationDate: Date
	let checkinIdsWithRiskPerDate: [Date: [CheckinIdWithRisk]]
	let riskLevelPerDate: [Date: RiskLevel]
}

struct CheckinIdWithRisk: Codable {
	let checkinId: Int
	let riskLevel: RiskLevel
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
