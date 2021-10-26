////
// 🦠 Corona-Warn-App
//

import Foundation

struct TestResultMetadata: Codable {
	
	// MARK: - Init
	
	init(registrationToken: String, testType: CoronaTestType) {
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
		checkinRiskLevelAtTestRegistration = try container.decodeIfPresent(RiskLevel.self, forKey: .checkinRiskLevelAtTestRegistration)
		daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration = try container.decodeIfPresent(
			Int.self,
			forKey: .daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration
		)
		hoursSinceCheckinHighRiskWarningAtTestRegistration = try container.decodeIfPresent(
			Int.self,
			forKey: .hoursSinceCheckinHighRiskWarningAtTestRegistration
		)
		exposureWindowsAtTestRegistration = try container.decodeIfPresent(
			[SubmissionExposureWindow].self,
			forKey: .exposureWindowsAtTestRegistration
		)
		testRegistrationDate = try container.decodeIfPresent(Date.self, forKey: .testRegistrationDate)
		testRegistrationToken = try container.decode(String.self, forKey: .testRegistrationToken)

		// TestType was introduced at a later time, thus it can be nil.
		// To assure backwards compatibility, assign .pcr if its nil.
		if let _type = try? container.decode(CoronaTestType.self, forKey: .testType) {
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
		case checkinRiskLevelAtTestRegistration
		case daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration
		case hoursSinceCheckinHighRiskWarningAtTestRegistration
		case exposureWindowsAtTestRegistration
		case testRegistrationDate
		case testRegistrationToken
		case testType
	}
	
	// MARK: - Internal
	
	// pending, positive or negative only
	var testResult: TestResult?
	
	// positive or negative “First time received” = time of test result - time of test registration
	// Pending: "every time" current timestamp - time of test registration
	var hoursSinceTestRegistration: Int? = 0
	
	// the ENF risk level at test registration.
	// Note: Do not rename or write migration
	var riskLevelAtTestRegistration: RiskLevel?
	
	// test registration date - Most Recent Date at ENF RiskLevel.
	// set to -1 when no most recent data is available
	// Note: Do not rename or write migration
	var daysSinceMostRecentDateAtRiskLevelAtTestRegistration: Int?
	
	// if high = timestamp of when the ENF risk got high -  timestamp of test registration
	// if low = -1
	// Note: Do not rename or write migration
	var hoursSinceHighRiskWarningAtTestRegistration: Int?
	
	// the checkin risk level at test registration
	var checkinRiskLevelAtTestRegistration: RiskLevel?
	
	// test registration date - Most Recent Date at checkin RiskLevel
	// set to -1 when no most recent data is available
	var daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: Int?
	
	// if high = timestamp of when the checkin risk got high -  timestamp of test registration
	// if low = -1
	var hoursSinceCheckinHighRiskWarningAtTestRegistration: Int?
	
	// Set of Exposure Windows that are available in ENF upon test registration.
	var exposureWindowsAtTestRegistration: [SubmissionExposureWindow]?
	
	// The following variables are not part of the submitted data but we need them for calculating the saved data
	
	var testRegistrationDate: Date?
	
	// We need a copy of the token to compare it every time we fetch a testResult to make sure it is a result for the QRCode test and not a TAN test submission
	let testRegistrationToken: String

	let testType: CoronaTestType

	var protobuf: SAP_Internal_Ppdd_PPATestResult? {
		switch (testType, testResult) {
		case (.pcr, .pending):
			return .testResultPending
		case (.pcr, .negative):
			return .testResultNegative
		case (.pcr, .positive):
			return .testResultPositive
		case (.pcr, .expired), (.pcr, .invalid):
			return nil
		case (.antigen, .pending):
			return .testResultRatPending
		case (.antigen, .negative):
			return .testResultRatNegative
		case (.antigen, .positive):
			return .testResultRatPositive
		case (.antigen, .expired), (.antigen, .invalid):
			return nil
		case (_, .none):
			return nil
		}
	}
}
