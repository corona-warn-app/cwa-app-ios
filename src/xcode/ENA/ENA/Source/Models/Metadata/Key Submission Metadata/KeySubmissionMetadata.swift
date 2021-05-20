//
// 🦠 Corona-Warn-App
//

import Foundation

struct KeySubmissionMetadata: Codable {

	// MARK: - Init

	init(
		submitted: Bool,
		submittedInBackground: Bool,
		submittedAfterCancel: Bool,
		submittedAfterSymptomFlow: Bool,
		lastSubmissionFlowScreen: LastSubmissionFlowScreen,
		advancedConsentGiven: Bool,
		hoursSinceTestResult: Int32,
		hoursSinceTestRegistration: Int32,
		daysSinceMostRecentDateAtENFRiskLevelAtTestRegistration: Int32,
		hoursSinceENFHighRiskWarningAtTestRegistration: Int32,
		daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: Int32,
		hoursSinceCheckinHighRiskWarningAtTestRegistration: Int32,
		submittedWithCheckIns: Bool?
	) {
		self.submitted = submitted
		self.submittedInBackground = submittedInBackground
		self.submittedAfterCancel = submittedAfterCancel
		self.submittedAfterSymptomFlow = submittedAfterSymptomFlow
		self.lastSubmissionFlowScreen = lastSubmissionFlowScreen
		self.advancedConsentGiven = advancedConsentGiven
		self.hoursSinceTestResult = hoursSinceTestResult
		self.hoursSinceTestRegistration = hoursSinceTestRegistration
		self.daysSinceMostRecentDateAtENFRiskLevelAtTestRegistration = daysSinceMostRecentDateAtENFRiskLevelAtTestRegistration
		self.hoursSinceENFHighRiskWarningAtTestRegistration = hoursSinceENFHighRiskWarningAtTestRegistration
		self.submittedWithCheckIns = submittedWithCheckIns
	}

	// MARK: - Protocol Codable

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		submitted = try container.decodeIfPresent(Bool.self, forKey: .submitted)
		submittedInBackground = try container.decodeIfPresent(Bool.self, forKey: .submittedInBackground)
		submittedAfterCancel = try container.decodeIfPresent(Bool.self, forKey: .submittedAfterCancel)
		submittedAfterSymptomFlow = try container.decodeIfPresent(Bool.self, forKey: .submittedAfterSymptomFlow)
		lastSubmissionFlowScreen = try container.decodeIfPresent(LastSubmissionFlowScreen.self, forKey: .lastSubmissionFlowScreen)
		advancedConsentGiven = try container.decodeIfPresent(Bool.self, forKey: .advancedConsentGiven)
		hoursSinceTestResult = try container.decodeIfPresent(Int32.self, forKey: .hoursSinceTestResult)
		hoursSinceTestRegistration = try container.decodeIfPresent(Int32.self, forKey: .hoursSinceTestRegistration)
		daysSinceMostRecentDateAtENFRiskLevelAtTestRegistration = try container.decodeIfPresent(Int32.self, forKey: .daysSinceMostRecentDateAtENFRiskLevelAtTestRegistration)
		hoursSinceENFHighRiskWarningAtTestRegistration = try container.decodeIfPresent(Int32.self, forKey: .hoursSinceENFHighRiskWarningAtTestRegistration)
		daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration = try container.decodeIfPresent(Int32.self, forKey: .daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration)
		hoursSinceCheckinHighRiskWarningAtTestRegistration = try container.decodeIfPresent(Int32.self, forKey: .hoursSinceCheckinHighRiskWarningAtTestRegistration)
		submittedWithCheckIns = try container.decodeIfPresent(Bool.self, forKey: .submittedWithCheckIns)
	}
	
	enum CodingKeys: String, CodingKey {
		case submitted
		case submittedInBackground
		case submittedAfterCancel
		case submittedAfterSymptomFlow
		case lastSubmissionFlowScreen
		case advancedConsentGiven
		case hoursSinceTestResult
		case hoursSinceTestRegistration
		case daysSinceMostRecentDateAtENFRiskLevelAtTestRegistration
		case hoursSinceENFHighRiskWarningAtTestRegistration
		case daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration
		case hoursSinceCheckinHighRiskWarningAtTestRegistration
		case submittedWithTeleTAN
		case submittedWithCheckIns
	}
	
	// MARK: - Internal
	
	var submitted: Bool?
	var submittedInBackground: Bool?
	var submittedAfterCancel: Bool?
	var submittedAfterSymptomFlow: Bool?
	var lastSubmissionFlowScreen: LastSubmissionFlowScreen?
	var advancedConsentGiven: Bool?
	var hoursSinceTestResult: Int32?
	var hoursSinceTestRegistration: Int32?
	var daysSinceMostRecentDateAtENFRiskLevelAtTestRegistration: Int32?
	var hoursSinceENFHighRiskWarningAtTestRegistration: Int32?
	var daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: Int32?
	var hoursSinceCheckinHighRiskWarningAtTestRegistration: Int32?
	var submittedWithTeleTAN: Bool?
	var submittedWithCheckIns: Bool?
}
