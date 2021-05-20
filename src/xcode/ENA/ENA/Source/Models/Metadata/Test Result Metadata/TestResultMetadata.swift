////
// 🦠 Corona-Warn-App
//

import Foundation

struct TestResultMetadata: Codable {
	
	// MARK: - Init
	
	init(registrationToken: String) {
		self.testRegistrationToken = registrationToken
	}

	// MARK: - Protocol Codable
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		testResult = try container.decodeIfPresent(TestResult.self, forKey: .testResult)
		hoursSinceTestRegistration = try container.decodeIfPresent(Int.self, forKey: .hoursSinceTestRegistration)
		enfRiskLevelAtTestRegistration = try container.decodeIfPresent(RiskLevel.self, forKey: .enfRiskLevelAtTestRegistration)
		daysSinceMostRecentDateAtENFRiskLevelAtTestRegistration = try container.decodeIfPresent(
			Int.self,
			forKey: .daysSinceMostRecentDateAtENFRiskLevelAtTestRegistration
		)
		hoursSinceENFHighRiskWarningAtTestRegistration = try container.decodeIfPresent(
			Int.self,
			forKey: .hoursSinceENFHighRiskWarningAtTestRegistration
		)
		checkinRiskLevelAtTestRegistration = try container.decodeIfPresent(RiskLevel.self, forKey: .checkinRiskLevelAtTestRegistration)
		daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration = try container.decodeIfPresent(
			Int.self,
			forKey: .daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration
		)
		hoursSinceCheckinHighRiskWarningAtTestRegistration = try container.decodeIfPresent(
			Int.self,
			forKey: .hoursSinceCheckinHighRiskWarningAtTestRegistration
		)
		testRegistrationDate = try container.decodeIfPresent(Date.self, forKey: .testRegistrationDate)
		testRegistrationToken = try container.decode(String.self, forKey: .testRegistrationToken)
	}
	
	enum CodingKeys: String, CodingKey {
		case testResult
		case hoursSinceTestRegistration
		case enfRiskLevelAtTestRegistration
		case daysSinceMostRecentDateAtENFRiskLevelAtTestRegistration
		case hoursSinceENFHighRiskWarningAtTestRegistration
		case checkinRiskLevelAtTestRegistration
		case daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration
		case hoursSinceCheckinHighRiskWarningAtTestRegistration
		case testRegistrationDate
		case testRegistrationToken
	}
	
	// MARK: - Internal
	
	// pending, positive or negative only
	var testResult: TestResult?
	
	// positive or negative “First time received” = time of test result - time of test registration
	// Pending: "everytime" current timestamp - time of test registration
	var hoursSinceTestRegistration: Int? = 0
	
	// the ENF risk level at test registration
	var enfRiskLevelAtTestRegistration: RiskLevel?
	
	// test registration date - Most Recent Date at ENF RiskLevel.
	// set to -1 when no most recent data is available
	var daysSinceMostRecentDateAtENFRiskLevelAtTestRegistration: Int?
	
	// if high = timestamp of when the ENF risk got high -  timestamp of test registration
	// if low = -1
	var hoursSinceENFHighRiskWarningAtTestRegistration: Int?
	
	// the checkin risk level at test registration
	var checkinRiskLevelAtTestRegistration: RiskLevel?
	
	// test registration date - Most Recent Date at checkin RiskLevel
	// set to -1 when no most recent data is available
	var daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: Int?
	
	// if high = timestamp of when the checkin risk got high -  timestamp of test registration
	// if low = -1
	var hoursSinceCheckinHighRiskWarningAtTestRegistration: Int?
	
	// The following variables are not part of the submitted data but we need them for calculating the saved data
	
	var testRegistrationDate: Date?
	
	// We need a copy of the token to compare it everytime we fetch a testResult to make sure it is a result for the QRCode test and not a TAN test submission
	let testRegistrationToken: String
}
