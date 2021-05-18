////
// 🦠 Corona-Warn-App
//

import Foundation

struct TestResultMetadata: Codable {

	enum TestType: Int, Codable {
		case pcr
		case antigen
	}
	
	// MARK: - Init
	
	init(registrationToken: String, testType: TestType) {
		self.testRegistrationToken = registrationToken
		self.testType = testType
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
		testRegistrationToken = try container.decode(String.self, forKey: .testRegistrationToken)

		// TestType was introduced at a later time, thus it can be nil.
		// To assure backwards compatibility, assign .pcr if its nil.
		if let _type = try? container.decode(TestType.self, forKey: .testType) {
			testType = _type
		} else {
			testType = .pcr
		}
	}
	
	enum CodingKeys: String, CodingKey {
		case testResult
		case hoursSinceTestRegistration
		case riskLevelAtTestRegistration
		case daysSinceMostRecentDateAtRiskLevelAtTestRegistration
		case hoursSinceHighRiskWarningAtTestRegistration
		case testRegistrationDate
		case testRegistrationToken
		case testType
	}
	
	// MARK: - Internal
	
	// pending, positive or negative only
	var testResult: TestResult?
	
	// positive or negative “First time received” = time of test result - time of test registration
	// Pending: "everytime" current timestamp - time of test registration
	var hoursSinceTestRegistration: Int? = 0
	
	// the risk level on the riskcard i.e totalRiskLevel
	var riskLevelAtTestRegistration: RiskLevel?
	
	// test registration date - Most Recent Date at RiskLevel
	var daysSinceMostRecentDateAtRiskLevelAtTestRegistration: Int?
	
	// if high = timestamp of when the risk card turned red -  timestamp of test registration
	// if low = -1
	var hoursSinceHighRiskWarningAtTestRegistration: Int?
	
	// The following variables are not part of the submitted data but we need them For calculating the saved data
	
	var testRegistrationDate: Date?
	
	// We need a copy of the token to compare it everytime we fetch a testResult to make sure it is a result for the QRCode test and not a TAN test submission
	let testRegistrationToken: String

	let testType: TestType

	var protobuf: SAP_Internal_Ppdd_PPATestResult? {
		switch (testType, testResult) {
		case (.pcr, .pending):
			return .testResultPending
		case (.pcr, .negative):
			return .testResultNegative
		case (.pcr, .positive):
			return .testResultPositive
		case (.pcr, .invalid):
			return .testResultInvalid
		case (.pcr, .expired):
			return nil
		case (.antigen, .pending):
			return .testResultRatPending
		case (.antigen, .negative):
			return .testResultRatNegative
		case (.antigen, .positive):
			return .testResultRatPositive
		case (.antigen, .invalid):
			return .testResultRatInvalid
		case (.antigen, .expired):
			return nil
		case (_, .none):
			return nil
		}
	}
}
