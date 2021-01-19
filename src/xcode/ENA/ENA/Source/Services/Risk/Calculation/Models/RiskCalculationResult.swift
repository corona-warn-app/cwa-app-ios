//
// 🦠 Corona-Warn-App
//

import Foundation

struct RiskCalculationResult: Codable {

	// MARK: - Internal

	let riskLevel: RiskLevel

	let minimumDistinctEncountersWithLowRisk: Int
	let minimumDistinctEncountersWithHighRisk: Int

	let mostRecentDateWithLowRisk: Date?
	let mostRecentDateWithHighRisk: Date?

	let numberOfDaysWithLowRisk: Int
	let numberOfDaysWithHighRisk: Int

	let calculationDate: Date
	let riskLevelPerDate: [Date: RiskLevel]

	var minimumDistinctEncountersWithCurrentRiskLevel: Int {
		switch riskLevel {
		case .low:
			return minimumDistinctEncountersWithLowRisk
		case .high:
			return minimumDistinctEncountersWithHighRisk
		}
	}

	var mostRecentDateWithCurrentRiskLevel: Date? {
		switch riskLevel {
		case .low:
			return mostRecentDateWithLowRisk
		case .high:
			return mostRecentDateWithHighRisk
		}
	}

	var numberOfDaysWithCurrentRiskLevel: Int {
		switch riskLevel {
		case .low:
			return numberOfDaysWithLowRisk
		case .high:
			return numberOfDaysWithHighRisk
		}
	}

}

extension Risk.Details {

	init(
		activeTracing: ActiveTracing,
		riskCalculationResult: RiskCalculationResult
	) {
		self.init(
			mostRecentDateWithRiskLevel: riskCalculationResult.mostRecentDateWithCurrentRiskLevel,
			numberOfDaysWithRiskLevel: riskCalculationResult.numberOfDaysWithCurrentRiskLevel,
			activeTracing: activeTracing,
			exposureDetectionDate: riskCalculationResult.calculationDate
		)
	}

}

extension Risk {

	init(
		activeTracing: ActiveTracing,
		riskCalculationResult: RiskCalculationResult,
		previousRiskCalculationResult: RiskCalculationResult? = nil
	) {
		let riskLevelHasChanged = previousRiskCalculationResult?.riskLevel != nil && riskCalculationResult.riskLevel != previousRiskCalculationResult?.riskLevel

		self.init(
			level: riskCalculationResult.riskLevel == .high ? .high : .low,
			details: Details(activeTracing: activeTracing, riskCalculationResult: riskCalculationResult),
			riskLevelHasChanged: riskLevelHasChanged
		)
	}

}
