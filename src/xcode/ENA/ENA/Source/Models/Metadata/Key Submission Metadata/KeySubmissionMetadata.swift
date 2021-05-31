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
		daysSinceMostRecentDateAtRiskLevelAtTestRegistration: Int32,
		hoursSinceHighRiskWarningAtTestRegistration: Int32,
		submittedWithTeleTAN: Bool,
		submittedAfterRapidAntigenTest: Bool,
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
		self.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = daysSinceMostRecentDateAtRiskLevelAtTestRegistration
		self.submittedWithTeleTAN = submittedWithTeleTAN
		self.submittedAfterRapidAntigenTest = submittedAfterRapidAntigenTest
		self.hoursSinceHighRiskWarningAtTestRegistration = hoursSinceHighRiskWarningAtTestRegistration
		self.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration = daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration
		self.hoursSinceCheckinHighRiskWarningAtTestRegistration = hoursSinceCheckinHighRiskWarningAtTestRegistration
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
		daysSinceMostRecentDateAtRiskLevelAtTestRegistration = try container.decodeIfPresent(Int32.self, forKey: .daysSinceMostRecentDateAtRiskLevelAtTestRegistration)
		hoursSinceHighRiskWarningAtTestRegistration = try container.decodeIfPresent(Int32.self, forKey: .hoursSinceHighRiskWarningAtTestRegistration)
		submittedWithTeleTAN = try container.decodeIfPresent(Bool.self, forKey: .submittedWithTeleTAN)
		submittedAfterRapidAntigenTest = try container.decodeIfPresent(Bool.self, forKey: .submittedAfterRapidAntigenTest) ?? false
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
		case daysSinceMostRecentDateAtRiskLevelAtTestRegistration
		case hoursSinceHighRiskWarningAtTestRegistration
		case submittedWithTeleTAN
		case submittedAfterRapidAntigenTest
		case daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration
		case hoursSinceCheckinHighRiskWarningAtTestRegistration
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
	// the enf risk version. Note: Do not rename or write migration
	var daysSinceMostRecentDateAtRiskLevelAtTestRegistration: Int32?
	// the enf risk  version. Note: Do not rename or write migration
	var hoursSinceHighRiskWarningAtTestRegistration: Int32?
	var submittedWithTeleTAN: Bool?
	var submittedAfterRapidAntigenTest: Bool = false
	// the checkin risk version
	var daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: Int32?
	// the checkin risk version
	var hoursSinceCheckinHighRiskWarningAtTestRegistration: Int32?
	var submittedWithCheckIns: Bool?
}
