////
// 🦠 Corona-Warn-App
//

import Foundation

class KeySubmissionService {

	// MARK: - Init

	init(store: Store) {
		self.secureStore = store
	}
	
	// MARK: - Internal

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
		guard let resultDateTimeStamp = secureStore.testResultReceivedTimeStamp else {
			return
		}
		
		let timeInterval = TimeInterval(resultDateTimeStamp)
		let resultDate = Date(timeIntervalSince1970: timeInterval)
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
	
	// MARK: - Private
	
	private var secureStore: Store
}
