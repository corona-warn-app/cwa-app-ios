////
// 🦠 Corona-Warn-App
//

extension SAP_Internal_V2_NormalizedTimeToRiskLevelMapping.RiskLevel: Codable { }

struct CheckinRiskCalculationResult: Codable {
	let checkinIdsWithRiskPerDate: [Date: [CheckinIdWithRisk]]
	let riskLevelPerDate: [Date: SAP_Internal_V2_NormalizedTimeToRiskLevelMapping.RiskLevel]
}

struct CheckinIdWithRisk: Codable {
	let checkinId: Int
	let riskLevel: SAP_Internal_V2_NormalizedTimeToRiskLevelMapping.RiskLevel
}
