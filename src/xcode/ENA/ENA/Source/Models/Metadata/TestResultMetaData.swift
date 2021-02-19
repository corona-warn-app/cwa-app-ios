////
// 🦠 Corona-Warn-App
//

import Foundation

struct TestResultMetaData: Codable {
	
	// MARK: - Init
	
	init(registrationToken: String) {
		self.testRegistrationToken = registrationToken
	}

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
		testRegistrationDate = try container.decodeIfPresent(Date.self, forKey: .testRegistrationDate)
		testRegistrationToken = try container.decode(String.self, forKey: .testRegistrationDate)
	}
	
	enum CodingKeys: String, CodingKey {
		case testResult
		case hoursSinceTestRegistration
		case riskLevelAtTestRegistration
		case daysSinceMostRecentDateAtRiskLevelAtTestRegistration
		case hoursSinceHighRiskWarningAtTestRegistration
		case testRegistrationDate
		case testRegistrationToken
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
	
	// The following variables are not part of the submitted data but we need them For calculating the saved data
	
	var testRegistrationDate: Date?
	
	// We need a copy of the token to compare it everytime we fetch a testResult to make sure it is a result for the QRCode test and not a TAN test submission
	let testRegistrationToken: String
}
