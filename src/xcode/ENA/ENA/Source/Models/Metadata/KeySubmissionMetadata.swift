//
// 🦠 Corona-Warn-App
//

import Foundation

struct KeySubmissionMetadata: Codable {
	var submitted: Bool
	var submittedInBackground: Bool
	var submittedAfterCancel: Bool
	var submittedAfterSymptomFlow: Bool
	var lastSubmissionFlowScreen: LastSubmissionFlowScreen
	var advancedConsentGiven: Bool
	var hoursSinceTestResult: Int
	var hoursSinceTestRegistration: Int
	var daysSinceMostRecentDateAtRiskLevelAtTestRegistration: Int
	var hoursSinceHighRiskWarningAtTestRegistration: Int
	var submittedWithTeleTAN: Bool

	enum CodingKeys: String, CodingKey {
		case submitted
		case submittedInBackground
		case submittedAfterCancel
		case submittedAfterSymptomFlow
		case lastSubmissionFlowScreen
		case advancedConsentGiven
		case hoursSinceTestResult
		case hoursSinceTestRegistration
		case daysSinceMostRecentDateAtRiskLevelAtTestRegistration
		case hoursSinceHighRiskWarningAtTestRegistration
		case submittedWithTeleTAN
	}

	init(
		submitted: Bool,
		submittedInBackground: Bool,
		submittedAfterCancel: Bool,
		submittedAfterSymptomFlow: Bool,
		lastSubmissionFlowScreen: LastSubmissionFlowScreen,
		advancedConsentGiven: Bool,
		hoursSinceTestResult: Int,
		hoursSinceTestRegistration: Int,
		daysSinceMostRecentDateAtRiskLevelAtTestRegistration: Int,
		hoursSinceHighRiskWarningAtTestRegistration: Int,
		submittedWithTeleTAN: Bool
	) {
		self.submitted = submitted
		self.submittedInBackground = submittedInBackground
		self.submittedAfterCancel = submittedAfterCancel
		self.submittedAfterSymptomFlow = submittedAfterSymptomFlow
		self.lastSubmissionFlowScreen = lastSubmissionFlowScreen
		self.advancedConsentGiven = advancedConsentGiven
		self.hoursSinceTestResult = hoursSinceTestResult
		self.hoursSinceTestRegistration = hoursSinceTestRegistration
		self.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = daysSinceMostRecentDateAtRiskLevelAtTestRegistration
		self.hoursSinceHighRiskWarningAtTestRegistration = hoursSinceHighRiskWarningAtTestRegistration
		self.submittedWithTeleTAN = submittedWithTeleTAN
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		submitted = try container.decode(Bool.self, forKey: .submitted)
		submittedInBackground = try container.decode(Bool.self, forKey: .submittedInBackground)
		submittedAfterCancel = try container.decode(Bool.self, forKey: .submittedAfterCancel)
		submittedAfterSymptomFlow = try container.decode(Bool.self, forKey: .submittedAfterSymptomFlow)
		lastSubmissionFlowScreen = try container.decode(LastSubmissionFlowScreen.self, forKey: .lastSubmissionFlowScreen)
		advancedConsentGiven = try container.decode(Bool.self, forKey: .advancedConsentGiven)
		hoursSinceTestResult = try container.decode(Int.self, forKey: .hoursSinceTestResult)
		hoursSinceTestRegistration = try container.decode(Int.self, forKey: .hoursSinceTestRegistration)
		daysSinceMostRecentDateAtRiskLevelAtTestRegistration = try container.decode(Int.self, forKey: .daysSinceMostRecentDateAtRiskLevelAtTestRegistration)
		hoursSinceHighRiskWarningAtTestRegistration = try container.decode(Int.self, forKey: .hoursSinceHighRiskWarningAtTestRegistration)
		submittedWithTeleTAN = try container.decode(Bool.self, forKey: .submittedWithTeleTAN)
	}
}
