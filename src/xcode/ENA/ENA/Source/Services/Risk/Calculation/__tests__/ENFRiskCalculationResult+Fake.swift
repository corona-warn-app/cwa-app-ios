//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension ENFRiskCalculationResult {

	// MARK: - Init

	static func fake(
		riskLevel: RiskLevel = .low,
		minimumDistinctEncountersWithLowRisk: Int = 0,
		minimumDistinctEncountersWithHighRisk: Int = 0,
		mostRecentDateWithLowRisk: Date? = nil,
		mostRecentDateWithHighRisk: Date? = nil,
		numberOfDaysWithLowRisk: Int = 0,
		numberOfDaysWithHighRisk: Int = 0,
		calculationDate: Date = Date(),
		riskLevelPerDate: [Date: RiskLevel] = [:],
		minimumDistinctEncountersWithHighRiskPerDate: [Date: Int] = [:]
	) -> ENFRiskCalculationResult {
		ENFRiskCalculationResult(
			riskLevel: riskLevel,
			minimumDistinctEncountersWithLowRisk: minimumDistinctEncountersWithLowRisk,
			minimumDistinctEncountersWithHighRisk: minimumDistinctEncountersWithHighRisk,
			mostRecentDateWithLowRisk: mostRecentDateWithLowRisk,
			mostRecentDateWithHighRisk: mostRecentDateWithHighRisk,
			numberOfDaysWithLowRisk: numberOfDaysWithLowRisk,
			numberOfDaysWithHighRisk: numberOfDaysWithHighRisk,
			calculationDate: calculationDate,
			riskLevelPerDate: riskLevelPerDate,
			minimumDistinctEncountersWithHighRiskPerDate: minimumDistinctEncountersWithHighRiskPerDate
		)
	}

}
