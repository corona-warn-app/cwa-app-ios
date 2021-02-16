////
// 🦠 Corona-Warn-App
//

import Foundation

struct TestResultMetaData: Codable {
	
	// MARK: - Public properties

	//pending, positive or negative only
	var testRsult: TestResult?

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
	
	// MARK: - Init

	init() {}
		
	// MARK: - Init from decoder

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		testRsult = try container.decodeIfPresent(TestResult.self, forKey: .testRsult)
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
	
	// MARK: - CodingKeys

	enum CodingKeys: String, CodingKey {
		case testRsult
		case hoursSinceTestRegistration
		case riskLevelAtTestRegistration
		case daysSinceMostRecentDateAtRiskLevelAtTestRegistration
		case hoursSinceHighRiskWarningAtTestRegistration
	}

}
