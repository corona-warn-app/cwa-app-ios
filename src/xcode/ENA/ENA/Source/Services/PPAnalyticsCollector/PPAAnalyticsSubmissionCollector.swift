////
// 🦠 Corona-Warn-App
//

import Foundation

final class PPAAnalyticsSubmissionCollector {

	init(
		store: Store,
		coronaTestService: CoronaTestService
	) {
		// We put the PPAnalyticsData protocol and its implementation in a seperate file because this protocol is only used by the collector. And only the collector should use it!
		// This way we avoid the direct access of analytics data at other places over the store.
		guard let store = store as? (Store & PPAnalyticsData) else {
			Log.error("I will never submit any analytics data. Could not cast to correct store protocol", log: .ppa)
			fatalError("I will never submit any analytics data. Could not cast to correct store protocol")
		}

		self.store = store
		self.coronaTestService = coronaTestService
	}

	// MARK: - Internal

	// swiftlint:disable:next cyclomatic_complexity
	func logKeySubmissionMetadata(_ keySubmissionMetadata: PPAKeySubmissionMetadata) {
		switch keySubmissionMetadata {
		case let .create(metadata, type):
			switch type {
			case .pcr:
				store.keySubmissionMetadata = metadata
			case .antigen:
				store.antigenKeySubmissionMetadata = metadata
			}
		case let .submitted(submitted, type):
			switch type {
			case .pcr:
				store.keySubmissionMetadata?.submitted = submitted
			case .antigen:
				store.antigenKeySubmissionMetadata?.submitted = submitted
			}
		case let .submittedInBackground(inBackground, type):
			switch type {
			case .pcr:
				store.keySubmissionMetadata?.submittedInBackground = inBackground
			case .antigen:
				store.antigenKeySubmissionMetadata?.submittedInBackground = inBackground
			}
		case let .submittedAfterCancel(afterCancel, type):
			switch type {
			case .pcr:
				store.keySubmissionMetadata?.submittedAfterCancel = afterCancel
			case .antigen:
				store.antigenKeySubmissionMetadata?.submittedAfterCancel = afterCancel
			}
		case let .submittedAfterSymptomFlow(afterSymptomFlow, type):
			switch type {
			case .pcr:
				store.keySubmissionMetadata?.submittedAfterSymptomFlow = afterSymptomFlow
			case .antigen:
				store.antigenKeySubmissionMetadata?.submittedAfterSymptomFlow = afterSymptomFlow
			}
		case let .submittedWithTeletan(withTeletan, type):
			switch type {
			case .pcr:
				store.keySubmissionMetadata?.submittedWithTeleTAN = withTeletan
			case .antigen:
				store.antigenKeySubmissionMetadata?.submittedWithTeleTAN = withTeletan
			}
		case let .lastSubmissionFlowScreen(flowScreen, type):
			switch type {
			case .pcr:
				store.keySubmissionMetadata?.lastSubmissionFlowScreen = flowScreen
			case .antigen:
				store.antigenKeySubmissionMetadata?.lastSubmissionFlowScreen = flowScreen
			}
		case let .advancedConsentGiven(advanceConsent, type):
			switch type {
			case .pcr:
				// this is as per techspecs, this value is false in case TAN submission
				if store.keySubmissionMetadata?.submittedWithTeleTAN == true {
					store.keySubmissionMetadata?.advancedConsentGiven = false
				} else {
					store.keySubmissionMetadata?.advancedConsentGiven = advanceConsent
				}
			case .antigen:
				// this is as per techspecs, this value is false in case TAN submission
				if store.antigenKeySubmissionMetadata?.submittedWithTeleTAN == true {
					store.antigenKeySubmissionMetadata?.advancedConsentGiven = false
				} else {
					store.antigenKeySubmissionMetadata?.advancedConsentGiven = advanceConsent
				}
			}
		case let .submittedAfterRapidAntigenTest(type):
			switch type {
			case .pcr:
				store.keySubmissionMetadata?.submittedAfterRapidAntigenTest = false
			case .antigen:
				store.antigenKeySubmissionMetadata?.submittedAfterRapidAntigenTest = true
			}
		case let .setHoursSinceTestResult(type):
			setHoursSinceTestResult(type: type)
		case let .setHoursSinceTestRegistration(type):
			setHoursSinceTestRegistration(type: type)
		case let .setHoursSinceHighRiskWarningAtTestRegistration(type):
			setHoursSinceHighRiskWarningAtTestRegistration(type: type)
		case let .setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration(type):
			setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration(type: type)
		}
	}

	// MARK: - Private

	private var store: PPAnalyticsData & StoreProtocol
	private var coronaTestService: CoronaTestService

	private func setHoursSinceTestResult(type: CoronaTestType) {
		guard let testResultReceivedDate = coronaTestService.coronaTest(ofType: type)?.finalTestResultReceivedDate else {
			Log.warning("Could not log hoursSinceTestResult due to testResultReceivedTimeStamp is nil", log: .ppa)
			return
		}

		let diffComponents = Calendar.current.dateComponents([.hour], from: testResultReceivedDate, to: Date())
		let hours = Int32(diffComponents.hour ?? 0)
		persistHoursSinceTestResult(hours, for: type)
	}

	private func persistHoursSinceTestResult(_ hours: Int32, for type: CoronaTestType) {
		switch type {
		case .pcr:
			store.keySubmissionMetadata?.hoursSinceTestResult = hours
		case .antigen:
			store.antigenKeySubmissionMetadata?.hoursSinceTestResult = hours
		}
	}

	private func setHoursSinceTestRegistration(type: CoronaTestType) {
		guard let registrationDate = coronaTestService.coronaTest(ofType: type)?.registrationDate else {
			Log.warning("Could not log hoursSinceTestRegistration due to testRegistrationDate is nil", log: .ppa)
			return
		}

		let diffComponents = Calendar.current.dateComponents([.hour], from: registrationDate, to: Date())
		let hours = Int32(diffComponents.hour ?? 0)
		persistHoursSinceTestRegistration(hours, for: type)
	}

	private func persistHoursSinceTestRegistration(_ hours: Int32, for type: CoronaTestType) {
		switch type {
		case .pcr:
			store.keySubmissionMetadata?.hoursSinceTestRegistration = hours
		case .antigen:
			store.antigenKeySubmissionMetadata?.hoursSinceTestRegistration = hours
		}
	}

	private func setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration(type: CoronaTestType) {
		guard let registrationDate = coronaTestService.coronaTest(ofType: type)?.registrationDate else {
			store.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = -1
			return
		}
		if let mostRecentRiskCalculationDate = store.enfRiskCalculationResult?.mostRecentDateWithCurrentRiskLevel {
			let daysSinceMostRecentDateAtRiskLevelAtTestRegistration = Calendar.utcCalendar.dateComponents([.day], from: mostRecentRiskCalculationDate, to: registrationDate).day
			let days = Int32(daysSinceMostRecentDateAtRiskLevelAtTestRegistration ?? -1)
			persistDaysSinceMostRecentDateAtRiskLevelAtTestRegistration(days, for: type)
		} else {
			persistDaysSinceMostRecentDateAtRiskLevelAtTestRegistration(-1, for: type)
		}
	}

	private func persistDaysSinceMostRecentDateAtRiskLevelAtTestRegistration(_ days: Int32, for type: CoronaTestType) {
		switch type {
		case .pcr:
			store.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = days
		case .antigen:
			store.antigenKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = days
		}
	}

	private func setHoursSinceHighRiskWarningAtTestRegistration(type: CoronaTestType) {
		guard let riskLevel = store.enfRiskCalculationResult?.riskLevel  else {
			Log.warning("Could not log hoursSinceHighRiskWarningAtTestRegistration due to riskLevel is nil", log: .ppa)
			return
		}
		switch riskLevel {
		case .high:

			let _registrationTime: Date?
			switch type {
			case .pcr:
				_registrationTime = coronaTestService.pcrTest?.registrationDate
			case .antigen:
				_registrationTime = coronaTestService.antigenTest?.registrationDate
			}

			guard let timeOfRiskChangeToHigh = store.dateOfConversionToHighRisk,
				  let registrationTime = _registrationTime else {
				Log.warning("Could not log risk calculation result due to timeOfRiskChangeToHigh is nil", log: .ppa)
				return
			}
			let differenceInHours = Calendar.current.dateComponents([.hour], from: timeOfRiskChangeToHigh, to: registrationTime)
			let hours = Int32(differenceInHours.hour ?? -1)
			persistHoursSinceHighRiskWarningAtTestRegistration(hours, for: type)
		case .low:
			persistHoursSinceHighRiskWarningAtTestRegistration(-1, for: type)
		}
	}

	private func persistHoursSinceHighRiskWarningAtTestRegistration(_ hours: Int32, for type: CoronaTestType) {
		switch type {
		case .pcr:
			store.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration = hours
		case .antigen:
			store.antigenKeySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration = hours
		}
	}
}
