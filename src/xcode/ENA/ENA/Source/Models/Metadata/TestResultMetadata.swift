////
// 🦠 Corona-Warn-App
//

import Foundation

struct TestResultMetadata: Codable {
	
	// MARK: - Init
	
	init() {}
	
	// MARK: - Protocol Codable
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		testResult = try container.decodeIfPresent(TestResult.self, forKey: .testResult)
		hoursSinceTestRegistration = try container.decodeIfPresent(Int.self, forKey: .hoursSinceTestRegistration)
		riskLevelAtTestRegistration = try container.decodeIfPresent(RiskLevel.self, forKey: .riskLevelAtTestRegistration)
		daysSinceMostRecentDateAtRiskLevelAtTestRegistration = try container.decodeIfPresent(
			Int.self,
			forKey: .daysSinceMostRecentDateAtRiskLevelAtTestRegistration
		)
		hoursSinceHighRiskWarningAtTestRegistration = try container.decodeIfPresent(
			Int.self,
			forKey: .hoursSinceHighRiskWarningAtTestRegistration
		)
	}
	
	enum CodingKeys: String, CodingKey {
		case testResult
		case hoursSinceTestRegistration
		case riskLevelAtTestRegistration
		case daysSinceMostRecentDateAtRiskLevelAtTestRegistration
		case hoursSinceHighRiskWarningAtTestRegistration
	}
	
	// MARK: - Internal
	
	// pending, positive or negative only
	var testResult: TestResult?
	
	// positive or negative “First time received” = time of test result - time of test registration
	// Pending: "everytime" current timestamp - time of test registration
	var hoursSinceTestRegistration: Int? = 0
	
	// the risk level on the riskcard i.e totalRiskLevel
	var riskLevelAtTestRegistration: RiskLevel?
	
	// Number of days on the risk card
	var daysSinceMostRecentDateAtRiskLevelAtTestRegistration: Int?
	
	// if high = timestamp of when the risk card turned red -  timestamp of test registration
	// if low = -1
	var hoursSinceHighRiskWarningAtTestRegistration: Int?
	
	var testRegistrationDate: Date?
}
