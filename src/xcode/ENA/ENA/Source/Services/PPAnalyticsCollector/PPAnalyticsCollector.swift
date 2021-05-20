////
// 🦠 Corona-Warn-App
//

import Foundation

typealias Analytics = PPAnalyticsCollector

/// To avoid that someone instantiate this, we made a enum. This collects the analytics data, makes in some cases some calculations and to save it to the database, to load it from the database, to remove every analytics data from the store. This enum also triggers a submission and grants that nothing can be logged if the user did not give his consent.
enum PPAnalyticsCollector {

	// MARK: - Internal

	/// Setup Analytics for regular use. We expect here a secure store.
	static func setup(
		store: Store,
		coronaTestService: CoronaTestService,
		submitter: PPAnalyticsSubmitting,
		testResultCollector: PPAAnalyticsTestResultCollector
	) {
		// We put the PPAnalyticsData protocol and its implementation in a seperate file because this protocol is only used by the collector. And only the collector should use it!
		// This way we avoid the direct access of analytics data at other places over the store.
		guard let store = store as? (Store & PPAnalyticsData) else {
			Log.error("I will never submit any analytics data. Could not cast to correct store protocol", log: .ppa)
			fatalError("I will never submit any analytics data. Could not cast to correct store protocol")
		}

		PPAnalyticsCollector.store = store
		PPAnalyticsCollector.coronaTestService = coronaTestService
		PPAnalyticsCollector.submitter = submitter
		PPAnalyticsCollector.testResultCollector = testResultCollector
	}

	/// The main purpose for the collector. Call this method to log some analytics data and pass the corresponding enums.
	static func collect(_ dataType: PPADataType) {
		// Make sure the user consent is given. If not, we must not log something.
		guard let consent = store?.isPrivacyPreservingAnalyticsConsentGiven,
			  consent == true else {
			Log.info("Forbidden to log any analytics data due to missing user consent", log: .ppa)
			return
		}

		Log.debug("Logging analytics data: \(private: dataType, public: "Some private analytics data")", log: .ppa)

		switch dataType {
		case let .userData(userMetadata):
			Analytics.logUserMetadata(userMetadata)
		case let .riskExposureMetadata(riskExposureMetadata):
			Analytics.logRiskExposureMetadata(riskExposureMetadata)
		case let .testResultMetadata(TestResultMetadata):
			testResultCollector?.logTestResultMetadata(TestResultMetadata)
		case let .keySubmissionMetadata(keySubmissionMetadata):
			Analytics.logKeySubmissionMetadata(keySubmissionMetadata)
		case let .exposureWindowsMetadata(exposureWindowsMetadata):
			Analytics.logExposureWindowsMetadata(exposureWindowsMetadata)
		case let .submissionMetadata(submissionMetadata):
			Analytics.logSubmissionMetadata(submissionMetadata)
		}

		// At the end, try to submit the data. In the submitter are all the checks that we do not submit the data to often.
		Analytics.triggerAnalyticsSubmission()
	}

	/// This removes all stored analytics data that we collected.
	static func deleteAnalyticsData() {
		store?.currentRiskExposureMetadata = nil
		store?.previousRiskExposureMetadata = nil
		store?.userMetadata = nil
		store?.lastSubmittedPPAData = nil
		store?.lastAppReset = nil
		store?.lastSubmissionAnalytics = nil
		store?.clientMetadata = nil
		store?.testResultMetadata = nil
		store?.antigenTestResultMetadata = nil
		store?.keySubmissionMetadata = nil
		store?.antigenKeySubmissionMetadata = nil
		store?.exposureWindowsMetadata = nil
		Log.info("Deleted all analytics data in the store", log: .ppa)
	}

	/// Triggers the submission of all collected analytics data. Only if all checks success, the submission is done. Otherwise, the submission is aborted. Optionally, you can specify a completion handler to get the success or failure handlers.
	static func triggerAnalyticsSubmission(completion: ((Result<Void, PPASError>) -> Void)? = nil) {
		guard let submitter = submitter else {
			Log.warning("I cannot submit analytics data. Perhaps i am a mock or setup was not called correctly?", log: .ppa)
			return
		}
		submitter.triggerSubmitData(completion: completion)
	}

	// MARK: - Private

	// Wrapper property to add a collect when the store is nil and we want to access it.
	private static var store: (Store & PPAnalyticsData)? {
		get {
			if _store == nil {
				Log.error("I cannot collect or read analytics data. Perhaps i am a mock or setup was not called correctly?", log: .ppa)
			}
			return _store
		}
		set {
			_store = newValue
		}
	}

	// The real store property.
	private static var _store: (Store & PPAnalyticsData)?
	private static var coronaTestService: CoronaTestService?
	private static var submitter: PPAnalyticsSubmitting?
	private static var testResultCollector: PPAAnalyticsTestResultCollector?

	// MARK: - UserMetada
	
	private static func logUserMetadata(_ userMetadata: PPAUserMetadata) {
		switch userMetadata {
		case let .create(metaData):
			store?.userMetadata = metaData
		}
	}

	// MARK: - RiskExposureMetadata

	private static func logRiskExposureMetadata(_ riskExposureMetadata: PPARiskExposureMetadata) {
		switch riskExposureMetadata {
		case let .create(metaData):
			store?.currentRiskExposureMetadata = metaData
		case let .updateRiskExposureMetadata(riskCalculationResult):
			Analytics.updateRiskExposureMetadata(riskCalculationResult)
		}
	}

	private static func updateRiskExposureMetadata(_ enfRiskCalculationResult: ENFRiskCalculationResult) {
		let riskLevel = enfRiskCalculationResult.riskLevel
		let riskLevelChangedComparedToPreviousSubmission: Bool
		let dateChangedComparedToPreviousSubmission: Bool

		// if there is a risk level value stored for previous submission
		if store?.previousRiskExposureMetadata?.riskLevel != nil {
			if riskLevel !=
				store?.previousRiskExposureMetadata?.riskLevel {
				// if there is a change in risk level
				riskLevelChangedComparedToPreviousSubmission = true
			} else {
				// if there is no change in risk level
				riskLevelChangedComparedToPreviousSubmission = false
			}
		} else {
			// for the first time, the field is set to false
			riskLevelChangedComparedToPreviousSubmission = false
		}

		// if there is most recent date store for previous submission
		if store?.previousRiskExposureMetadata?.mostRecentDateAtRiskLevel != nil {
			if enfRiskCalculationResult.mostRecentDateWithCurrentRiskLevel !=
				store?.previousRiskExposureMetadata?.mostRecentDateAtRiskLevel {
				// if there is a change in date
				dateChangedComparedToPreviousSubmission = true
			} else {
				// if there is no change in date
				dateChangedComparedToPreviousSubmission = false
			}
		} else {
			// for the first time, the field is set to false
			dateChangedComparedToPreviousSubmission = false
		}

		guard let mostRecentDateWithCurrentRiskLevel = enfRiskCalculationResult.mostRecentDateWithCurrentRiskLevel else {
			// most recent date is not available because of no exposure
			let newRiskExposureMetadata = RiskExposureMetadata(
				riskLevel: riskLevel,
				riskLevelChangedComparedToPreviousSubmission: riskLevelChangedComparedToPreviousSubmission,
				dateChangedComparedToPreviousSubmission: dateChangedComparedToPreviousSubmission
			)
			Analytics.collect(.riskExposureMetadata(.create(newRiskExposureMetadata)))
			return
		}
		let newRiskExposureMetadata = RiskExposureMetadata(
			riskLevel: riskLevel,
			riskLevelChangedComparedToPreviousSubmission: riskLevelChangedComparedToPreviousSubmission,
			mostRecentDateAtRiskLevel: mostRecentDateWithCurrentRiskLevel,
			dateChangedComparedToPreviousSubmission: dateChangedComparedToPreviousSubmission
		)
		Analytics.collect(.riskExposureMetadata(.create(newRiskExposureMetadata)))
	}

	// MARK: - KeySubmissionMetadata

	// swiftlint:disable:next cyclomatic_complexity
	private static func logKeySubmissionMetadata(_ keySubmissionMetadata: PPAKeySubmissionMetadata) {
		switch keySubmissionMetadata {
		case let .create(metadata, type):
			switch type {
			case .pcr:
				store?.keySubmissionMetadata = metadata
			case .antigen:
				store?.antigenKeySubmissionMetadata = metadata
			}
		case let .submitted(submitted, type):
			switch type {
			case .pcr:
				store?.keySubmissionMetadata?.submitted = submitted
			case .antigen:
				store?.antigenKeySubmissionMetadata?.submitted = submitted
			}
		case let .submittedInBackground(inBackground, type):
			switch type {
			case .pcr:
				store?.keySubmissionMetadata?.submittedInBackground = inBackground
			case .antigen:
				store?.antigenKeySubmissionMetadata?.submittedInBackground = inBackground
			}
		case let .submittedAfterCancel(afterCancel, type):
			switch type {
			case .pcr:
				store?.keySubmissionMetadata?.submittedAfterCancel = afterCancel
			case .antigen:
				store?.antigenKeySubmissionMetadata?.submittedAfterCancel = afterCancel
			}
		case let .submittedAfterSymptomFlow(afterSymptomFlow, type):
			switch type {
			case .pcr:
				store?.keySubmissionMetadata?.submittedAfterSymptomFlow = afterSymptomFlow
			case .antigen:
				store?.antigenKeySubmissionMetadata?.submittedAfterSymptomFlow = afterSymptomFlow
			}
		case let .submittedWithTeletan(withTeletan, type):
			switch type {
			case .pcr:
				store?.keySubmissionMetadata?.submittedWithTeleTAN = withTeletan
			case .antigen:
				store?.antigenKeySubmissionMetadata?.submittedWithTeleTAN = withTeletan
			}
		case let .lastSubmissionFlowScreen(flowScreen, type):
			switch type {
			case .pcr:
				store?.keySubmissionMetadata?.lastSubmissionFlowScreen = flowScreen
			case .antigen:
				store?.antigenKeySubmissionMetadata?.lastSubmissionFlowScreen = flowScreen
			}
		case let .advancedConsentGiven(advanceConsent, type):
			switch type {
			case .pcr:
				// this is as per techspecs, this value is false in case TAN submission
				if store?.keySubmissionMetadata?.submittedWithTeleTAN == false && advanceConsent == true {
					store?.keySubmissionMetadata?.advancedConsentGiven = advanceConsent
				} else {
					store?.keySubmissionMetadata?.advancedConsentGiven = false
				}
			case .antigen:
				// this is as per techspecs, this value is false in case TAN submission
				if store?.antigenKeySubmissionMetadata?.submittedWithTeleTAN == false && advanceConsent == true {
					store?.antigenKeySubmissionMetadata?.advancedConsentGiven = advanceConsent
				} else {
					store?.antigenKeySubmissionMetadata?.advancedConsentGiven = false
				}
			}
		case let .hoursSinceTestResult(hours, type):
			switch type {
			case .pcr:
				store?.keySubmissionMetadata?.hoursSinceTestResult = hours
			case .antigen:
				store?.antigenKeySubmissionMetadata?.hoursSinceTestResult = hours
			}
		case let .keySubmissionHoursSinceTestRegistration(hours, type):
			switch type {
			case .pcr:
				store?.keySubmissionMetadata?.hoursSinceTestRegistration = hours
			case .antigen:
				store?.antigenKeySubmissionMetadata?.hoursSinceTestRegistration = hours
			}
		case let .daysSinceMostRecentDateAtRiskLevelAtTestRegistration(date, type):
			switch type {
			case .pcr:
				store?.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = date
			case .antigen:
				store?.antigenKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = date
			}
		case let .hoursSinceHighRiskWarningAtTestRegistration(hours, type):
			switch type {
			case .pcr:
				store?.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration = hours
			case .antigen:
				store?.antigenKeySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration = hours
			}
		case let .setHoursSinceTestResult(type):
			Analytics.setHoursSinceTestResult(type: type)
		case let .setHoursSinceTestRegistration(type):
			Analytics.setHoursSinceTestRegistration(type: type)
		case let .setHoursSinceHighRiskWarningAtTestRegistration(type):
			Analytics.setHoursSinceHighRiskWarningAtTestRegistration(type: type)
		case let .setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration(type):
			Analytics.setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration(type: type)
		}
	}

	private static func setHoursSinceTestResult(type: CoronaTestType) {
		guard let testResultReceivedDate = testResultReceivedDate(for: type) else {
			Log.warning("Could not log hoursSinceTestResult due to testResultReceivedTimeStamp is nil", log: .ppa)
			return
		}

		let diffComponents = Calendar.current.dateComponents([.hour], from: testResultReceivedDate, to: Date())
		let hours = Int32(diffComponents.hour ?? 0)
		persistHoursSinceTestResult(hours, for: type)
	}

	private static func testResultReceivedDate(for type: CoronaTestType) -> Date? {
		switch type {
		case .pcr:
			return coronaTestService?.pcrTest?.finalTestResultReceivedDate
		case .antigen:
			return coronaTestService?.antigenTest?.finalTestResultReceivedDate
		}
	}

	private static func persistHoursSinceTestResult(_ hours: Int32, for type: CoronaTestType) {
		switch type {
		case .pcr:
			store?.keySubmissionMetadata?.hoursSinceTestResult = hours
		case .antigen:
			store?.antigenKeySubmissionMetadata?.hoursSinceTestResult = hours
		}
	}

	private static func setHoursSinceTestRegistration(type: CoronaTestType) {
		guard let registrationDate = testRegistrationDate(for: type) else {
			Log.warning("Could not log hoursSinceTestRegistration due to testRegistrationDate is nil", log: .ppa)
			return
		}

		let diffComponents = Calendar.current.dateComponents([.hour], from: registrationDate, to: Date())
		let hours = Int32(diffComponents.hour ?? 0)
		persistHoursSinceTestRegistration(hours, for: type)
	}

	private static func testRegistrationDate(for type: CoronaTestType) -> Date? {
		switch type {
		case .pcr:
			return coronaTestService?.pcrTest?.registrationDate
		case .antigen:
			return coronaTestService?.antigenTest?.registrationDate
		}
	}

	private static func persistHoursSinceTestRegistration(_ hours: Int32, for type: CoronaTestType) {
		switch type {
		case .pcr:
			store?.keySubmissionMetadata?.hoursSinceTestRegistration = hours
		case .antigen:
			store?.antigenKeySubmissionMetadata?.hoursSinceTestRegistration = hours
		}
	}

	private static func setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration(type: CoronaTestType) {
		guard let registrationDate = testRegistrationDate(for: type) else {
			store?.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = -1
			return
		}
		if let mostRecentRiskCalculationDate = store?.enfRiskCalculationResult?.mostRecentDateWithCurrentRiskLevel {
			let daysSinceMostRecentDateAtRiskLevelAtTestRegistration = Calendar.utcCalendar.dateComponents([.day], from: mostRecentRiskCalculationDate, to: registrationDate).day
			let days = Int32(daysSinceMostRecentDateAtRiskLevelAtTestRegistration ?? -1)
			persistDaysSinceMostRecentDateAtRiskLevelAtTestRegistration(days, for: type)
		} else {
			persistDaysSinceMostRecentDateAtRiskLevelAtTestRegistration(-1, for: type)
		}
	}

	private static func persistDaysSinceMostRecentDateAtRiskLevelAtTestRegistration(_ days: Int32, for type: CoronaTestType) {
		switch type {
		case .pcr:
			store?.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = days
		case .antigen:
			store?.antigenKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = days
		}
	}

	private static func setHoursSinceHighRiskWarningAtTestRegistration(type: CoronaTestType) {
		guard let riskLevel = store?.enfRiskCalculationResult?.riskLevel  else {
			Log.warning("Could not log hoursSinceHighRiskWarningAtTestRegistration due to riskLevel is nil", log: .ppa)
			return
		}
		switch riskLevel {
		case .high:
			guard let timeOfRiskChangeToHigh = store?.dateOfConversionToHighRisk,
				  let registrationTime = coronaTestService?.pcrTest?.registrationDate else {
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

	private static func persistHoursSinceHighRiskWarningAtTestRegistration(_ hours: Int32, for type: CoronaTestType) {
		switch type {
		case .pcr:
			store?.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration = hours
		case .antigen:
			store?.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration = hours
		}
	}

	// MARK: - ExposureWindowsMetadata

	private static func logExposureWindowsMetadata(_ exposureWindowsMetadata: PPAExposureWindowsMetadata) {
		switch exposureWindowsMetadata {
		case let .collectExposureWindows(exposureWindows):
			Log.info("Create new ExposureWindowsMetadata from: \(String(describing: exposureWindows.count)) riskCalculation windows", log: .ppa)
			Analytics.collectExposureWindows(exposureWindows)
		}
	}

	private static func collectExposureWindows(_ riskCalculationWindows: [RiskCalculationExposureWindow]) {
		
		self.clearReportedExposureWindowsQueueIfNeeded()
		var mappedSubmissionExposureWindows: [SubmissionExposureWindow] = riskCalculationWindows.map {
			SubmissionExposureWindow(
				exposureWindow: $0.exposureWindow,
				transmissionRiskLevel: $0.transmissionRiskLevel,
				normalizedTime: $0.normalizedTime,
				hash: generateSHA256($0.exposureWindow),
				date: $0.date
			)
		}

		if let metadata = store?.exposureWindowsMetadata {
			// if store is initialized:
			// - Queue if new: if the hash of the Exposure Window not included in reportedExposureWindowsQueue, the Exposure Window is added to reportedExposureWindowsQueue.
			mappedSubmissionExposureWindows.removeAll(where: { window -> Bool in
				return metadata.reportedExposureWindowsQueue.contains(where: { $0.hash == window.hash })
			})
			store?.exposureWindowsMetadata?.newExposureWindowsQueue.append(contentsOf: mappedSubmissionExposureWindows)
			store?.exposureWindowsMetadata?.reportedExposureWindowsQueue.append(contentsOf: mappedSubmissionExposureWindows)
		} else {
			// if store is not initialized:
			// - Initialize and add all of the exposure windows to both "newExposureWindowsQueue" and "reportedExposureWindowsQueue" arrays
			store?.exposureWindowsMetadata = ExposureWindowsMetadata(
				newExposureWindowsQueue: mappedSubmissionExposureWindows,
				reportedExposureWindowsQueue: mappedSubmissionExposureWindows
			)
			Log.info("First submission of ExposureWindowsMetadata", log: .ppa)
		}
		Log.info("number of new ExposureWindowsMetadata windows: \(String(describing: store?.exposureWindowsMetadata?.newExposureWindowsQueue.count)) windows", log: .ppa)
		Log.info("number of reported ExposureWindowsMetadata windows: \(String(describing: store?.exposureWindowsMetadata?.reportedExposureWindowsQueue.count)) windows", log: .ppa)
	}

	private static func clearReportedExposureWindowsQueueIfNeeded() {
		if let nonExpiredWindows = store?.exposureWindowsMetadata?.reportedExposureWindowsQueue.filter({
			guard let day = Calendar.current.dateComponents([.day], from: $0.date, to: Date()).day else {
				Log.debug("Exposure Window is removed from reportedExposureWindowsQueue as the date component is nil", log: .ppa)
				return false
			}
			return day < 15
		}) {
			store?.exposureWindowsMetadata?.reportedExposureWindowsQueue = nonExpiredWindows
		}
	}

	private static func generateSHA256(_ window: ExposureWindow) -> String? {
		let encoder = JSONEncoder()
		do {
			let windowData = try encoder.encode(window)
			return windowData.sha256String()
		} catch {
			Log.error("ExposureWindow Encoding error", log: .ppa, error: error)
		}
		return nil
	}

	// MARK: - SubmissionMetadata

	private static func logSubmissionMetadata(_ submissionMetadata: PPASubmissionMetadata) {
		switch submissionMetadata {
		case let .lastAppReset(date):
			store?.lastAppReset = date
		}
	}
}

extension PPAnalyticsCollector {
	
	#if !RELEASE

	/// Setup Analytics for testing. The store or the submitter can be nil for testing purposes.
	static func setupMock(
		store: (Store & PPAnalyticsData)? = nil,
		submitter: PPAnalyticsSubmitter? = nil,
		coronaTestService: CoronaTestService? = nil
	) {
		PPAnalyticsCollector.store = store
		PPAnalyticsCollector.submitter = submitter
		PPAnalyticsCollector.coronaTestService = coronaTestService

		if let store = store {
			let testResultCollector = PPAAnalyticsTestResultCollector(store: store)
			PPAnalyticsCollector.testResultCollector = testResultCollector
		}
	}

	/// ONLY FOR TESTING. Returns the last successful submitted data.
	static func mostRecentAnalyticsData() -> String? {
		return store?.lastSubmittedPPAData
	}

	/// ONLY FOR TESTING. Return the constructed proto-file message to look into the data we have collected so far.
	static func getPPADataMessage() -> SAP_Internal_Ppdd_PPADataIOS? {
		guard let submitter = submitter else {
			Log.warning("I cannot get actual analytics data. Perhaps i am a mock or setup was not called correctly?")
			return nil
		}
		return submitter.getPPADataMessage()
	}

	/// ONLY FOR TESTING. Triggers for the dev menu a forced submission of the data, whithout any checks.
	static func forcedAnalyticsSubmission(completion: @escaping (Result<Void, PPASError>) -> Void) {
		guard let submitter = submitter else {
			Log.warning("I cannot trigger a forced submission. Perhaps i am a mock or setup was not called correctly?")
			return completion(.failure(.generalError))
		}
		return submitter.forcedSubmitData(completion: completion)
	}

	#endif
}
