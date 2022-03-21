////
// 🦠 Corona-Warn-App
//

import Foundation

final class PPAAnalyticsSubmissionCollector {

	init(
		store: Store,
		coronaTestService: CoronaTestServiceProviding
	) {
		// We put the PPAnalyticsData protocol and its implementation in a separate file because this protocol is only used by the collector. And only the collector should use it!
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
				store.pcrKeySubmissionMetadata = metadata
			case .antigen:
				store.antigenKeySubmissionMetadata = metadata
			}
		case let .submitted(submitted, type):
			switch type {
			case .pcr:
				store.pcrKeySubmissionMetadata?.submitted = submitted
			case .antigen:
				store.antigenKeySubmissionMetadata?.submitted = submitted
			}
		case let .submittedInBackground(inBackground, type):
			switch type {
			case .pcr:
				store.pcrKeySubmissionMetadata?.submittedInBackground = inBackground
			case .antigen:
				store.antigenKeySubmissionMetadata?.submittedInBackground = inBackground
			}
		case let .submittedAfterCancel(afterCancel, type):
			switch type {
			case .pcr:
				store.pcrKeySubmissionMetadata?.submittedAfterCancel = afterCancel
			case .antigen:
				store.antigenKeySubmissionMetadata?.submittedAfterCancel = afterCancel
			}
		case let .submittedAfterSymptomFlow(afterSymptomFlow, type):
			switch type {
			case .pcr:
				store.pcrKeySubmissionMetadata?.submittedAfterSymptomFlow = afterSymptomFlow
			case .antigen:
				store.antigenKeySubmissionMetadata?.submittedAfterSymptomFlow = afterSymptomFlow
			}
		case let .submittedWithTeletan(withTeletan, type):
			switch type {
			case .pcr:
				store.pcrKeySubmissionMetadata?.submittedWithTeleTAN = withTeletan
			case .antigen:
				store.antigenKeySubmissionMetadata?.submittedWithTeleTAN = withTeletan
			}
		case let .submittedWithCheckins(withCheckins, type):
			switch type {
			case .pcr:
				store.pcrKeySubmissionMetadata?.submittedWithCheckIns = withCheckins
			case .antigen:
				store.antigenKeySubmissionMetadata?.submittedWithCheckIns = withCheckins
			}
		case let .lastSubmissionFlowScreen(flowScreen, type):
			switch type {
			case .pcr:
				store.pcrKeySubmissionMetadata?.lastSubmissionFlowScreen = flowScreen
			case .antigen:
				store.antigenKeySubmissionMetadata?.lastSubmissionFlowScreen = flowScreen
			}
		case let .advancedConsentGiven(advanceConsent, type):
			switch type {
			case .pcr:
				// this is as per techspecs, this value is false in case TAN submission
				if store.pcrKeySubmissionMetadata?.submittedWithTeleTAN == true {
					store.pcrKeySubmissionMetadata?.advancedConsentGiven = false
				} else {
					store.pcrKeySubmissionMetadata?.advancedConsentGiven = advanceConsent
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
				store.pcrKeySubmissionMetadata?.submittedAfterRapidAntigenTest = false
			case .antigen:
				store.antigenKeySubmissionMetadata?.submittedAfterRapidAntigenTest = true
			}
		case let .setHoursSinceTestResult(type):
			setHoursSinceTestResult(type: type)
		case let .setHoursSinceTestRegistration(type):
			setHoursSinceTestRegistration(type: type)
		case let .setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration(type):
			setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration(type: type)
		case let .setHoursSinceENFHighRiskWarningAtTestRegistration(type):
			setHoursSinceENFHighRiskWarningAtTestRegistration(type: type)
		case let .setDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration(type):
			setDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration(type: type)
		case let .setHoursSinceCheckinHighRiskWarningAtTestRegistration(type):
			setHoursSinceCheckinHighRiskWarningAtTestRegistration(type: type)
		}
	}

	// MARK: - Private

	private var store: PPAnalyticsData & StoreProtocol
	private var coronaTestService: CoronaTestServiceProviding

	private func setHoursSinceTestResult(type: CoronaTestType) {
		guard let testResultReceivedDate = coronaTestService.userCoronaTest(ofType: type)?.finalTestResultReceivedDate else {
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
			store.pcrKeySubmissionMetadata?.hoursSinceTestResult = hours
		case .antigen:
			store.antigenKeySubmissionMetadata?.hoursSinceTestResult = hours
		}
	}

	private func setHoursSinceTestRegistration(type: CoronaTestType) {
		guard let registrationDate = coronaTestService.userCoronaTest(ofType: type)?.registrationDate else {
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
			store.pcrKeySubmissionMetadata?.hoursSinceTestRegistration = hours
		case .antigen:
			store.antigenKeySubmissionMetadata?.hoursSinceTestRegistration = hours
		}
	}

	private func setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration(type: CoronaTestType) {
		guard let registrationDate = coronaTestService.userCoronaTest(ofType: type)?.registrationDate else {
			switch type {
			case .pcr:
				store.pcrKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = -1
			case .antigen:
				store.antigenKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = -1
			}
			return
		}
		if let mostRecentRiskCalculationDate = store.enfRiskCalculationResult?.mostRecentDateWithCurrentRiskLevel {
			let daysSinceMostRecentDateAtRiskLevelAtTestRegistration = Calendar.utcCalendar.dateComponents([.day], from: mostRecentRiskCalculationDate, to: registrationDate).day
			let days = Int32(daysSinceMostRecentDateAtRiskLevelAtTestRegistration ?? -1)
			persistDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration(days, for: type)
		} else {
			persistDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration(-1, for: type)
		}
	}

	private func persistDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration(_ days: Int32, for type: CoronaTestType) {
		switch type {
		case .pcr:
			store.pcrKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = days
		case .antigen:
			store.antigenKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = days
		}
	}

	private func setHoursSinceENFHighRiskWarningAtTestRegistration(type: CoronaTestType) {
		guard let riskLevel = store.enfRiskCalculationResult?.riskLevel  else {
			Log.warning("Could not log hoursSinceHighRiskWarningAtTestRegistration due to riskLevel is nil", log: .ppa)
			return
		}
		switch riskLevel {
		case .high:

			let _registrationTime: Date?
			switch type {
			case .pcr:
				_registrationTime = coronaTestService.pcrTest.value?.registrationDate
			case .antigen:
				_registrationTime = coronaTestService.antigenTest.value?.registrationDate
			}

			guard let dateOfRiskChangeToHigh = store.dateOfConversionToENFHighRisk,
				  let registrationTime = _registrationTime else {
				Log.warning("Could not log risk calculation result due to timeOfRiskChangeToHigh is nil", log: .ppa)
				return
			}
			let differenceInHours = Calendar.current.dateComponents([.hour], from: dateOfRiskChangeToHigh, to: registrationTime)
			let hours = Int32(differenceInHours.hour ?? -1)
			persistHoursSinceENFHighRiskWarningAtTestRegistration(hours, for: type)
		case .low:
			persistHoursSinceENFHighRiskWarningAtTestRegistration(-1, for: type)
		}
	}

	private func persistHoursSinceENFHighRiskWarningAtTestRegistration(_ hours: Int32, for type: CoronaTestType) {
		switch type {
		case .pcr:
			store.pcrKeySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration = hours
		case .antigen:
			store.antigenKeySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration = hours
		}
	}
	
	private func setDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration(type: CoronaTestType) {
		guard let registrationDate = coronaTestService.userCoronaTest(ofType: type)?.registrationDate else {
			switch type {
			case .pcr:
				store.pcrKeySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration = -1
			case .antigen:
				store.antigenKeySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration = -1
			}
			return
		}
		if let mostRecentRiskCalculationDate = store.checkinRiskCalculationResult?.mostRecentDateWithCurrentRiskLevel {
			let daysSinceMostRecentDateAtRiskLevelAtTestRegistration = Calendar.utcCalendar.dateComponents([.day], from: mostRecentRiskCalculationDate, to: registrationDate).day
			let days = Int32(daysSinceMostRecentDateAtRiskLevelAtTestRegistration ?? -1)
			persistDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration(days, for: type)
		} else {
			persistDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration(-1, for: type)
		}
	}

	private func persistDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration(_ days: Int32, for type: CoronaTestType) {
		switch type {
		case .pcr:
			store.pcrKeySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration = days
		case .antigen:
			store.antigenKeySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration = days
		}
	}

	private func setHoursSinceCheckinHighRiskWarningAtTestRegistration(type: CoronaTestType) {
		guard let riskLevel = store.checkinRiskCalculationResult?.riskLevel  else {
			Log.warning("Could not log hoursSinceHighRiskWarningAtTestRegistration due to riskLevel is nil", log: .ppa)
			return
		}
		switch riskLevel {
		case .high:
			let _registrationTime: Date?
			switch type {
			case .pcr:
				_registrationTime = coronaTestService.pcrTest.value?.registrationDate
			case .antigen:
				_registrationTime = coronaTestService.antigenTest.value?.registrationDate
			}

			guard let dateOfRiskChangeToHigh = store.dateOfConversionToCheckinHighRisk,
				  let registrationTime = _registrationTime else {
				Log.warning("Could not log risk calculation result due to timeOfRiskChangeToHigh is nil", log: .ppa)
				return
			}
			let differenceInHours = Calendar.current.dateComponents([.hour], from: dateOfRiskChangeToHigh, to: registrationTime)
			let hours = Int32(differenceInHours.hour ?? -1)
			persistHoursSinceCheckinHighRiskWarningAtTestRegistration(hours, for: type)
		case .low:
			persistHoursSinceCheckinHighRiskWarningAtTestRegistration(-1, for: type)
		}
	}

	private func persistHoursSinceCheckinHighRiskWarningAtTestRegistration(_ hours: Int32, for type: CoronaTestType) {
		switch type {
		case .pcr:
			store.pcrKeySubmissionMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration = hours
		case .antigen:
			store.antigenKeySubmissionMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration = hours
		}
	}
}
