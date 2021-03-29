//
// 🦠 Corona-Warn-App
//

import Foundation

struct RiskCalculationResult: Codable {

	// MARK: - Init

	init(
		riskLevel: RiskLevel,
		minimumDistinctEncountersWithLowRisk: Int,
		minimumDistinctEncountersWithHighRisk: Int,
		mostRecentDateWithLowRisk: Date?,
		mostRecentDateWithHighRisk: Date?,
		numberOfDaysWithLowRisk: Int,
		numberOfDaysWithHighRisk: Int,
		calculationDate: Date,
		riskLevelPerDate: [Date: RiskLevel],
		minimumDistinctEncountersWithHighRiskPerDate: [Date: Int]
	) {
		self.riskLevel = riskLevel
		self.minimumDistinctEncountersWithLowRisk = minimumDistinctEncountersWithLowRisk
		self.minimumDistinctEncountersWithHighRisk = minimumDistinctEncountersWithHighRisk
		self.mostRecentDateWithLowRisk = mostRecentDateWithLowRisk
		self.mostRecentDateWithHighRisk = mostRecentDateWithHighRisk
		self.numberOfDaysWithLowRisk = numberOfDaysWithLowRisk
		self.numberOfDaysWithHighRisk = numberOfDaysWithHighRisk
		self.calculationDate = calculationDate
		self.riskLevelPerDate = riskLevelPerDate
		self.minimumDistinctEncountersWithHighRiskPerDate = minimumDistinctEncountersWithHighRiskPerDate
	}

	// MARK: - Protocol Decodable

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		riskLevel = try container.decode(RiskLevel.self, forKey: .riskLevel)

		minimumDistinctEncountersWithLowRisk = try container.decode(Int.self, forKey: .minimumDistinctEncountersWithLowRisk)
		minimumDistinctEncountersWithHighRisk = try container.decode(Int.self, forKey: .minimumDistinctEncountersWithHighRisk)

		mostRecentDateWithLowRisk = try container.decodeIfPresent(Date.self, forKey: .mostRecentDateWithLowRisk)
		mostRecentDateWithHighRisk = try container.decodeIfPresent(Date.self, forKey: .mostRecentDateWithHighRisk)

		numberOfDaysWithLowRisk = try container.decode(Int.self, forKey: .numberOfDaysWithLowRisk)
		numberOfDaysWithHighRisk = try container.decode(Int.self, forKey: .numberOfDaysWithHighRisk)

		calculationDate = try container.decode(Date.self, forKey: .calculationDate)
		riskLevelPerDate = try container.decodeIfPresent([Date: RiskLevel].self, forKey: .riskLevelPerDate) ?? [:]
		minimumDistinctEncountersWithHighRiskPerDate = try container.decodeIfPresent([Date: Int].self, forKey: .minimumDistinctEncountersWithHighRiskPerDate) ?? [:]
	}

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
	let minimumDistinctEncountersWithHighRiskPerDate: [Date: Int]

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
