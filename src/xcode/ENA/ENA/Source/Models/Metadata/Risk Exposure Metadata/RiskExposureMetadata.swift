//
// 🦠 Corona-Warn-App
//

import Foundation

struct RiskExposureMetadata: Codable, Equatable {

	// MARK: - Init

	init(
		riskLevel: RiskLevel,
		riskLevelChangedComparedToPreviousSubmission: Bool,
		mostRecentDateAtRiskLevel: Date?,
		dateChangedComparedToPreviousSubmission: Bool
	) {
		self.riskLevel = riskLevel
		self.riskLevelChangedComparedToPreviousSubmission = riskLevelChangedComparedToPreviousSubmission
		self.mostRecentDateAtRiskLevel = mostRecentDateAtRiskLevel
		self.dateChangedComparedToPreviousSubmission = dateChangedComparedToPreviousSubmission
	}

	init(
		riskLevel: RiskLevel,
		riskLevelChangedComparedToPreviousSubmission: Bool,
		dateChangedComparedToPreviousSubmission: Bool
	) {
		self.riskLevel = riskLevel
		self.riskLevelChangedComparedToPreviousSubmission = riskLevelChangedComparedToPreviousSubmission
		self.dateChangedComparedToPreviousSubmission = dateChangedComparedToPreviousSubmission
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		riskLevel = try container.decode(RiskLevel.self, forKey: .riskLevel)
		riskLevelChangedComparedToPreviousSubmission = try container.decode(Bool.self, forKey: .riskLevelChangedComparedToPreviousSubmission)
		mostRecentDateAtRiskLevel = try container.decodeIfPresent(Date.self, forKey: .mostRecentDateAtRiskLevel)
		dateChangedComparedToPreviousSubmission = try container.decode(Bool.self, forKey: .dateChangedComparedToPreviousSubmission)
	}

	// MARK: - Protocol Codable
	
	enum CodingKeys: String, CodingKey {
		case riskLevel
		case riskLevelChangedComparedToPreviousSubmission
		case mostRecentDateAtRiskLevel
		case dateChangedComparedToPreviousSubmission
	}
	
	// MARK: - Internal

	var riskLevel: RiskLevel
	var riskLevelChangedComparedToPreviousSubmission: Bool
	var mostRecentDateAtRiskLevel: Date?
	var dateChangedComparedToPreviousSubmission: Bool
}
