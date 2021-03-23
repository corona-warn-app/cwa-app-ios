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
		submitter: PPAnalyticsSubmitter
	) {
		// Make sure the secure store now also implements the PPAnalyticsData protocol with the properties defined there (the analytics data proporties).
		guard let store = store as? (Store & PPAnalyticsData) else {
			Log.error("I will never submit any analytics data. Could not cast to correct store protocol", log: .ppa)
			fatalError("I will never submit any analytics data. Could not cast to correct store protocol")
		}
		PPAnalyticsCollector.store = store
		PPAnalyticsCollector.submitter = submitter
	}

	/// The main purpose for the collector. Call this method to log some analytics data and pass the corresponding enums.
	static func collect(_ dataType: PPADataType) {

		// Make sure the user consent is given. If not, we must not log something.
		guard let consent = store?.isPrivacyPreservingAnalyticsConsentGiven,
			  consent == true else {
			Log.info("Forbidden to log any analytics data due to missing user consent", log: .ppa)
			return
		}

		Log.debug("Logging analytics data: \(dataType)", log: .ppa)
		switch dataType {
		case let .userData(userMetadata):
			Analytics.logUserMetadata(userMetadata)
		case let .riskExposureMetadata(riskExposureMetadata):
			Analytics.logRiskExposureMetadata(riskExposureMetadata)
		case let .clientMetadata(clientMetadata):
			Analytics.logClientMetadata(clientMetadata)
		case let .testResultMetadata(TestResultMetadata):
			Analytics.logTestResultMetadata(TestResultMetadata)
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
		store?.submittedWithQR = false
		store?.lastAppReset = nil
		store?.lastSubmissionAnalytics = nil
		store?.clientMetadata = nil
		store?.testResultMetadata = nil
		store?.keySubmissionMetadata = nil
		store?.exposureWindowsMetadata = nil
		Log.info("Deleted all analytics data in the store", log: .ppa)
	}

	/// Triggers the submission of all collected analytics data. Only if all checks success, the submission is done. Otherwise, the submission is aborted. Optionally, you can specify a completion handler to get the success or failure handlers.
	static func triggerAnalyticsSubmission(completion: ((Result<Void, PPASError>) -> Void)? = nil) {
		// fill in the risk exposure metadata if new risk calculation is not done in the meanwhile
		if let riskCalculationResult = store?.riskCalculationResult {
			updateRiskExposureMetadata(riskCalculationResult)
		}
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

	private static var submitter: PPAnalyticsSubmitter?

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

	private static func updateRiskExposureMetadata(_ riskCalculationResult: RiskCalculationResult) {
		let riskLevel = riskCalculationResult.riskLevel
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
			if riskCalculationResult.mostRecentDateWithCurrentRiskLevel !=
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

		guard let mostRecentDateWithCurrentRiskLevel = riskCalculationResult.mostRecentDateWithCurrentRiskLevel else {
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


	// MARK: - ClientMetadata

	private static func logClientMetadata(_ clientMetadata: PPAClientMetadata) {
		switch clientMetadata {
		case let .create(metaData):
			store?.clientMetadata = metaData
		case .setClientMetaData:
			Analytics.setClientMetaData()
		}
	}

	private static func setClientMetaData() {
		let eTag = store?.appConfigMetadata?.lastAppConfigETag
		Analytics.collect(.clientMetadata(.create(ClientMetadata(etag: eTag))))
	}

	// MARK: - TestResultMetadata

	private static func logTestResultMetadata(_ TestResultMetadata: PPATestResultMetadata) {
		switch TestResultMetadata {
		case let .create(metaData):
			store?.testResultMetadata = metaData
		case let .testResult(testResult):
			store?.testResultMetadata?.testResult = testResult
		case let .testResultHoursSinceTestRegistration(hoursSinceTestRegistration):
			store?.testResultMetadata?.hoursSinceTestRegistration = hoursSinceTestRegistration
		case let .updateTestResult(testResult, token):
			Analytics.updateTestResult(testResult, token)
		case let .registerNewTestMetadata(date, token):
			Analytics.registerNewTestMetadata(date, token)
		}
	}

	private static func updateTestResult(_ testResult: TestResult, _ token: String) {
		// we only save metadata for tests submitted on QR code,and there is the only place in the app where we set the registration date
		guard store?.testResultMetadata?.testRegistrationToken == token,
			  let registrationDate = store?.testResultMetadata?.testRegistrationDate else {
			Log.warning("Could not update test meta data result due to testRegistrationDate is nil", log: .ppa)
			return
		}

		let storedTestResult = store?.testResultMetadata?.testResult
		// if storedTestResult != newTestResult ---> update persisted testResult and the hoursSinceTestRegistration
		// if storedTestResult == nil ---> update persisted testResult and the hoursSinceTestRegistration
		// if storedTestResult == newTestResult ---> do nothing

		if storedTestResult == nil || storedTestResult != testResult {
			switch testResult {
			case .positive, .negative, .pending:
				Log.info("update TestResultMetadata with testResult: \(testResult.stringValue)", log: .ppa)
				Analytics.collect(.testResultMetadata(.testResult(testResult)))

				switch store?.testResultMetadata?.testResult {
				case .positive, .negative, .pending:
					let diffComponents = Calendar.current.dateComponents([.hour], from: registrationDate, to: Date())
					Analytics.collect(.testResultMetadata(.testResultHoursSinceTestRegistration(diffComponents.hour)))
					Log.info("update TestResultMetadata with HoursSinceTestRegistration: \(String(describing: diffComponents.hour))", log: .ppa)
				default:
					Analytics.collect(.testResultMetadata(.testResultHoursSinceTestRegistration(nil)))
				}

			case .expired, .invalid:
				break
			}
		} else {
			Log.warning("will not update same TestResultMetadata, oldResult: \(storedTestResult?.stringValue ?? "") newResult: \(testResult.stringValue)", log: .ppa)
		}
	}

	private static func registerNewTestMetadata(_ date: Date = Date(), _ token: String) {
		guard let riskCalculationResult = store?.riskCalculationResult else {
			Log.warning("Could not register new test meta data due to riskCalculationResult is nil", log: .ppa)
			return
		}
		var testResultMetadata = TestResultMetadata(registrationToken: token)
		testResultMetadata.testRegistrationDate = date
		testResultMetadata.riskLevelAtTestRegistration = riskCalculationResult.riskLevel
		testResultMetadata.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = riskCalculationResult.numberOfDaysWithCurrentRiskLevel

		Analytics.collect(.testResultMetadata(.create(testResultMetadata)))

		switch riskCalculationResult.riskLevel {
		case .high:
			guard let timeOfRiskChangeToHigh = store?.dateOfConversionToHighRisk else {
				Log.warning("Could not log risk calculation result due to timeOfRiskChangeToHigh is nil", log: .ppa)
				return
			}
			let differenceInHours = Calendar.current.dateComponents([.hour], from: timeOfRiskChangeToHigh, to: date)
			store?.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration = differenceInHours.hour
		case .low:
			store?.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration = -1
		}


	}

	// MARK: - KeySubmissionMetadata

	// swiftlint:disable:next cyclomatic_complexity
	private static func logKeySubmissionMetadata(_ keySubmissionMetadata: PPAKeySubmissionMetadata) {
		switch keySubmissionMetadata {
		case let .create(metadata):
			store?.keySubmissionMetadata = metadata
		case let .submitted(submitted):
			store?.keySubmissionMetadata?.submitted = submitted
		case let .submittedInBackground(inBackground):
			store?.keySubmissionMetadata?.submittedInBackground = inBackground
		case let .submittedAfterCancel(afterCancel):
			store?.keySubmissionMetadata?.submittedAfterCancel = afterCancel
		case let .submittedAfterSymptomFlow(afterSymptomFlow):
			store?.keySubmissionMetadata?.submittedAfterSymptomFlow = afterSymptomFlow
		case let .submittedWithTeletan(withTeletan):
			store?.submittedWithQR = !withTeletan
		case let .lastSubmissionFlowScreen(flowScreen):
			store?.keySubmissionMetadata?.lastSubmissionFlowScreen = flowScreen
		case let .advancedConsentGiven(advanceConsent):
			// this is as per techspecs, this value is false in case TAN submission
			if store?.submittedWithQR == true && advanceConsent == true {
				store?.keySubmissionMetadata?.advancedConsentGiven = advanceConsent
			} else {
				store?.keySubmissionMetadata?.advancedConsentGiven = false
			}
		case let .hoursSinceTestResult(hours):
			store?.keySubmissionMetadata?.hoursSinceTestResult = hours
		case let .keySubmissionHoursSinceTestRegistration(hours):
			store?.keySubmissionMetadata?.hoursSinceTestRegistration = hours
		case let .daysSinceMostRecentDateAtRiskLevelAtTestRegistration(date):
			store?.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = date
		case let .hoursSinceHighRiskWarningAtTestRegistration(hours):
			store?.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration = hours
		case .updateSubmittedWithTeletan:
			store?.keySubmissionMetadata?.submittedWithTeleTAN = !(store?.submittedWithQR ?? false)
		case .setHoursSinceTestResult:
			Analytics.setHoursSinceTestResult()
		case .setHoursSinceTestRegistration:
			Analytics.setHoursSinceTestRegistration()
		case .setHoursSinceHighRiskWarningAtTestRegistration:
			Analytics.setHoursSinceHighRiskWarningAtTestRegistration()
		case .setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration:
			Analytics.setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration()
		}
	}

	private static func setHoursSinceTestResult() {
		guard let resultDateTimeStamp = store?.testResultReceivedTimeStamp else {
			Log.warning("Could not log hoursSinceTestResult due to testResultReceivedTimeStamp is nil", log: .ppa)
			return
		}

		let timeInterval = TimeInterval(resultDateTimeStamp)
		let resultDate = Date(timeIntervalSince1970: timeInterval)
		let diffComponents = Calendar.current.dateComponents([.hour], from: resultDate, to: Date())
		store?.keySubmissionMetadata?.hoursSinceTestResult = Int32(diffComponents.hour ?? 0)
	}

	private static func setHoursSinceTestRegistration() {
		guard let registrationDate = store?.testRegistrationDate else {
			Log.warning("Could not log hoursSinceTestRegistration due to testRegistrationDate is nil", log: .ppa)
			return
		}

		let diffComponents = Calendar.current.dateComponents([.hour], from: registrationDate, to: Date())
		store?.keySubmissionMetadata?.hoursSinceTestRegistration = Int32(diffComponents.hour ?? 0)
	}

	private static func setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration() {
		guard let numberOfDaysWithCurrentRiskLevel = store?.riskCalculationResult?.numberOfDaysWithCurrentRiskLevel  else {
			Log.warning("Could not log daysSinceMostRecentDateAtRiskLevelAtTestRegistration due to numberOfDaysWithCurrentRiskLevel is nil", log: .ppa)
			return
		}
		store?.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = Int32(numberOfDaysWithCurrentRiskLevel)
	}

	private static func setHoursSinceHighRiskWarningAtTestRegistration() {
		guard let riskLevel = store?.riskCalculationResult?.riskLevel  else {
			Log.warning("Could not log hoursSinceHighRiskWarningAtTestRegistration due to riskLevel is nil", log: .ppa)
			return
		}
		switch riskLevel {
		case .high:
			guard let timeOfRiskChangeToHigh = store?.dateOfConversionToHighRisk,
				  let registrationTime = store?.testRegistrationDate else {
				Log.warning("Could not log risk calculation result due to timeOfRiskChangeToHigh is nil", log: .ppa)
				return
			}
			let differenceInHours = Calendar.current.dateComponents([.hour], from: timeOfRiskChangeToHigh, to: registrationTime)
			store?.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration = Int32(differenceInHours.hour ?? -1)
		case .low:
			store?.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration = -1
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

		let mappedSubmissionExposureWindows: [SubmissionExposureWindow] = riskCalculationWindows.map {
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
			for exposureWindow in mappedSubmissionExposureWindows {
				if !metadata.reportedExposureWindowsQueue.contains(where: { $0.hash == exposureWindow.hash }) {
					store?.exposureWindowsMetadata?.newExposureWindowsQueue.append(exposureWindow)
					store?.exposureWindowsMetadata?.reportedExposureWindowsQueue.append(exposureWindow)
				}
			}
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
		submitter: PPAnalyticsSubmitter? = nil
	) {
		PPAnalyticsCollector.store = store
		PPAnalyticsCollector.submitter = submitter
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
