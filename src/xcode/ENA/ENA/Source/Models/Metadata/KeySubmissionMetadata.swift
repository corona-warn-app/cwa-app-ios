//
// 🦠 Corona-Warn-App
//

import Foundation

struct KeySubmissionMetadata: Codable {
	var submitted: Bool?
	var submittedInBackground: Bool?
	var submittedAfterCancel: Bool?
	var submittedAfterSymptomFlow: Bool?
	var lastSubmissionFlowScreen: LastSubmissionFlowScreen?
	var advancedConsentGiven: Bool?
	var hoursSinceTestResult: Int32?
	var hoursSinceTestRegistration: Int32?
	var daysSinceMostRecentDateAtRiskLevelAtTestRegistration: Int32?
	var hoursSinceHighRiskWarningAtTestRegistration: Int32?
	var submittedWithTeleTAN: Bool?

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
		hoursSinceTestResult: Int32,
		hoursSinceTestRegistration: Int32,
		daysSinceMostRecentDateAtRiskLevelAtTestRegistration: Int32,
		hoursSinceHighRiskWarningAtTestRegistration: Int32,
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
	}
}

class KeySubmissionService {
	private var secureStore: Store
	
	init(store: Store) {
		self.secureStore = store
	}
	
	func setSubmitted(withValue: Bool = false) {
		secureStore.keySubmissionMetadata?.submitted = withValue
	}
	
	func setSubmittedInBackground(withValue: Bool = false) {
		secureStore.keySubmissionMetadata?.submittedInBackground = withValue
	}

	func setSubmittedAfterCancel(withValue: Bool = false) {
		secureStore.keySubmissionMetadata?.submittedAfterCancel = withValue
	}
	
	func setSubmittedAfterSymptomFlow(withValue: Bool = false) {
		secureStore.keySubmissionMetadata?.submittedAfterSymptomFlow = withValue
	}
	
	func setLastSubmissionFlowScreen(withValue: LastSubmissionFlowScreen = .submissionFlowScreenUnknown) {
		secureStore.keySubmissionMetadata?.lastSubmissionFlowScreen = withValue
	}

	func setAdvancedConsentGiven(withValue: Bool = false) {
		secureStore.keySubmissionMetadata?.advancedConsentGiven = withValue
	}

	func setHoursSinceTestResult() {
		guard let resultDate = secureStore.testResultDate else {
			return
		}
		
		let diffComponents = Calendar.current.dateComponents([.hour], from: resultDate, to: Date())
		secureStore.keySubmissionMetadata?.hoursSinceTestResult = Int32(diffComponents.hour ?? 0)
	}
	
	func setHoursSinceTestRegistration() {
		guard let registrationDate = secureStore.testRegistrationDate else {
			return
		}
		
		let diffComponents = Calendar.current.dateComponents([.hour], from: registrationDate, to: Date())
		secureStore.keySubmissionMetadata?.hoursSinceTestRegistration = Int32(diffComponents.hour ?? 0)
	}

	func setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration() {
		guard let numberOfDaysWithCurrentRiskLevel = secureStore.riskCalculationResult?.numberOfDaysWithCurrentRiskLevel  else {
			return
		}
		secureStore.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = Int32(numberOfDaysWithCurrentRiskLevel)
	}
	
	func setHoursSinceHighRiskWarningAtTestRegistration() {
		guard let riskLevel = secureStore.riskCalculationResult?.riskLevel  else {
			return
		}
		switch riskLevel {
		case .high:
			guard let timeOfRiskChangeToHigh = secureStore.dateOfConversionToHighRisk,
				  let registrationTime = secureStore.testRegistrationDate else {
				Log.debug("Time of risk status change was not stored correctly.")
				return
			}
			let differenceInHours = Calendar.current.dateComponents([.hour], from: timeOfRiskChangeToHigh, to: registrationTime)
			secureStore.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration = Int32(differenceInHours.hour ?? -1)
		case .low:
			secureStore.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration = -1
		}
	}
	
	func setSubmittedWithTeleTAN(withValue: Bool = true) {
		secureStore.keySubmissionMetadata?.submittedWithTeleTAN = withValue
	}
}
