////
// 🦠 Corona-Warn-App
//

import Foundation

typealias Analytics = PPAnalyticsCollector

/// To avoid that someone instantiate this, we made a enum. This collects the analytics data, makes in some cases some calculations and to save it to the database, to load it from the database, to remove every analytics data from the store. This enum also triggers a submission and grants that nothing can be logged if the user did not give his consent.
// swiftlint:disable type_body_length
// swiftlint:disable file_length
enum PPAnalyticsCollector {

	// MARK: - Internal

	/// Setup Analytics for regular use. We expect here a secure store.
	static func setup(
		store: Store,
		coronaTestService: CoronaTestService,
		submitter: PPAnalyticsSubmitter
	) {
		// Make sure the secure store now also implements the PPAnalyticsData protocol with the properties defined there (the analytics data proporties).
		guard let store = store as? (Store & PPAnalyticsData) else {
			Log.error("I will never submit any analytics data. Could not cast to correct store protocol", log: .ppa)
			fatalError("I will never submit any analytics data. Could not cast to correct store protocol")
		}
		PPAnalyticsCollector.store = store
		PPAnalyticsCollector.coronaTestService = coronaTestService
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

		Log.debug("Logging analytics data: \(private: dataType, public: "Some private analytics data")", log: .ppa)

		switch dataType {
		case let .userData(userMetadata):
			Analytics.logUserMetadata(userMetadata)
		case let .riskExposureMetadata(riskExposureMetadata):
			Analytics.logRiskExposureMetadata(riskExposureMetadata)
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
		store?.currentENFRiskExposureMetadata = nil
		store?.previousENFRiskExposureMetadata = nil
		store?.currentCheckinRiskExposureMetadata = nil
		store?.previousCheckinRiskExposureMetadata = nil
		store?.userMetadata = nil
		store?.lastSubmittedPPAData = nil
		store?.submittedWithQR = false
		store?.lastAppReset = nil
		store?.lastSubmissionAnalytics = nil
		store?.clientMetadata = nil
		store?.testResultMetadata = nil
		store?.keySubmissionMetadata = nil
		store?.exposureWindowsMetadata = nil
		store?.dateOfConversionToENFHighRisk = nil
		store?.dateOfConversionToCheckinHighRisk = nil

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
		case .update:
			Analytics.gatherRisksAndUpdateMetadata()
		}
	}
	
	private static func gatherRisksAndUpdateMetadata() {
		if let enfRiskCalculationResult = store?.enfRiskCalculationResult {
			updateENFRiskExposureMetadata(enfRiskCalculationResult)
		}
		if let checkinRiskCalculationResult = store?.checkinRiskCalculationResult {
			updateCheckinRiskExposureMetadata(checkinRiskCalculationResult)
		}
	}

	private static func updateENFRiskExposureMetadata(_ enfRiskCalculationResult: ENFRiskCalculationResult) {
		let riskLevel = enfRiskCalculationResult.riskLevel
		let previousRiskLevel = store?.previousENFRiskExposureMetadata?.riskLevel
		let mostRecentDateWithCurrentRiskLevel = enfRiskCalculationResult.mostRecentDateWithCurrentRiskLevel
		let previousMostRecentDateWithCurrentRiskLevel = store?.previousENFRiskExposureMetadata?.mostRecentDateAtRiskLevel
		let riskLevelChangedComparedToPreviousSubmission: Bool
		let dateChangedComparedToPreviousSubmission: Bool

		// If risk level is nil, set to false. Otherwise, set it when it changed compared to previous submission.
		riskLevelChangedComparedToPreviousSubmission = riskLevel != previousRiskLevel || !(previousRiskLevel == nil)
		
		// If mostRecentDateAtRiskLevel is nil, set to false. Otherwise, change itt when it changed compared to previous submission.
		dateChangedComparedToPreviousSubmission = mostRecentDateWithCurrentRiskLevel != previousMostRecentDateWithCurrentRiskLevel || !(previousMostRecentDateWithCurrentRiskLevel == nil)
		
		guard let mostRecentDateWithCurrentRiskLevel = enfRiskCalculationResult.mostRecentDateWithCurrentRiskLevel else {
			// most recent date is not available because of no exposure
			let newRiskExposureMetadata = RiskExposureMetadata(
				riskLevel: riskLevel,
				riskLevelChangedComparedToPreviousSubmission: riskLevelChangedComparedToPreviousSubmission,
				dateChangedComparedToPreviousSubmission: dateChangedComparedToPreviousSubmission
			)
			store?.currentENFRiskExposureMetadata = newRiskExposureMetadata
			return
		}
		let newRiskExposureMetadata = RiskExposureMetadata(
			riskLevel: riskLevel,
			riskLevelChangedComparedToPreviousSubmission: riskLevelChangedComparedToPreviousSubmission,
			mostRecentDateAtRiskLevel: mostRecentDateWithCurrentRiskLevel,
			dateChangedComparedToPreviousSubmission: dateChangedComparedToPreviousSubmission
		)
		store?.currentENFRiskExposureMetadata = newRiskExposureMetadata
	}
	
	private static func updateCheckinRiskExposureMetadata(_ checkinRiskCalculationResult: CheckinRiskCalculationResult) {
		let riskLevel = checkinRiskCalculationResult.riskLevel
		let previousRiskLevel = store?.previousCheckinRiskExposureMetadata?.riskLevel
		let mostRecentDateWithCurrentRiskLevel = checkinRiskCalculationResult.mostRecentDateWithCurrentRiskLevel
		let previousMostRecentDateWithCurrentRiskLevel = store?.previousCheckinRiskExposureMetadata?.mostRecentDateAtRiskLevel
		let riskLevelChangedComparedToPreviousSubmission: Bool
		let dateChangedComparedToPreviousSubmission: Bool

		// If risk level is nil, set to false. Otherwise, set it when it changed compared to previous submission.
		riskLevelChangedComparedToPreviousSubmission = riskLevel != previousRiskLevel || !(previousRiskLevel == nil)
		
		// If mostRecentDateAtRiskLevel is nil, set to false. Otherwise, change itt when it changed compared to previous submission.
		dateChangedComparedToPreviousSubmission = mostRecentDateWithCurrentRiskLevel != previousMostRecentDateWithCurrentRiskLevel || !(previousMostRecentDateWithCurrentRiskLevel == nil)

		guard let mostRecentDateWithCurrentRiskLevel = checkinRiskCalculationResult.mostRecentDateWithCurrentRiskLevel else {
			// most recent date is not available because of no exposure
			let newRiskExposureMetadata = RiskExposureMetadata(
				riskLevel: riskLevel,
				riskLevelChangedComparedToPreviousSubmission: riskLevelChangedComparedToPreviousSubmission,
				dateChangedComparedToPreviousSubmission: dateChangedComparedToPreviousSubmission
			)
			store?.currentCheckinRiskExposureMetadata = newRiskExposureMetadata
			return
		}
		let newRiskExposureMetadata = RiskExposureMetadata(
			riskLevel: riskLevel,
			riskLevelChangedComparedToPreviousSubmission: riskLevelChangedComparedToPreviousSubmission,
			mostRecentDateAtRiskLevel: mostRecentDateWithCurrentRiskLevel,
			dateChangedComparedToPreviousSubmission: dateChangedComparedToPreviousSubmission
		)
		store?.currentCheckinRiskExposureMetadata = newRiskExposureMetadata
		
	}

	// MARK: - TestResultMetadata

	private static func logTestResultMetadata(_ TestResultMetadata: PPATestResultMetadata) {
		switch TestResultMetadata {
		case let .testResultHoursSinceTestRegistration(hoursSinceTestRegistration):
			store?.testResultMetadata?.hoursSinceTestRegistration = hoursSinceTestRegistration
		case let .updateTestResult(testResult, token):
			Analytics.updateTestResult(testResult, token)
		case let .registerNewTestMetadata(date, token):
			Analytics.registerNewTestMetadata(date, token)
		case let .dateOfConversionToENFHighRisk(date):
			store?.dateOfConversionToENFHighRisk = date
		case let .dateOfConversionToCheckinHighRisk(date):
			store?.dateOfConversionToCheckinHighRisk = date
		}
	}

	// swiftlint:disable:next cyclomatic_complexity
	private static func registerNewTestMetadata(_ date: Date = Date(), _ token: String) {
		guard store?.enfRiskCalculationResult != nil || store?.checkinRiskCalculationResult != nil else {
			Log.warning("Could not register new test meta data due to enfRiskCalculationResult and checkinRiskCalculationResult are both nil", log: .ppa)
			return
		}
		
		var testResultMetadata = TestResultMetadata(registrationToken: token)
		testResultMetadata.testRegistrationDate = date
		
		// Differ between ENF and checkin risk calculation results.

		if let enfRiskCalculationResult = store?.enfRiskCalculationResult {
			testResultMetadata.riskLevelAtTestRegistration = enfRiskCalculationResult.riskLevel
			
			if let mostRecentRiskCalculationDate = enfRiskCalculationResult.mostRecentDateWithCurrentRiskLevel {
				let daysSinceMostRecentDateAtRiskLevelAtTestRegistration = Calendar.current.dateComponents([.day], from: mostRecentRiskCalculationDate, to: date).day
				testResultMetadata.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = daysSinceMostRecentDateAtRiskLevelAtTestRegistration
				Log.debug("daysSinceMostRecentDateAtRiskLevelAtTestRegistration: \(String(describing: daysSinceMostRecentDateAtRiskLevelAtTestRegistration))", log: .ppa)
			} else {
				testResultMetadata.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = -1
				Log.warning("daysSinceMostRecentDateAtRiskLevelAtTestRegistration: -1", log: .ppa)
			}
			
			switch enfRiskCalculationResult.riskLevel {
			case .high:
				if let timeOfRiskChangeToHigh = store?.dateOfConversionToENFHighRisk {
					let differenceInHours = Calendar.current.dateComponents([.hour], from: timeOfRiskChangeToHigh, to: date)
					testResultMetadata.hoursSinceHighRiskWarningAtTestRegistration = differenceInHours.hour
				} else {
					Log.warning("Could not log enf risk calculation result due to timeOfRiskChangeToHigh is nil", log: .ppa)
				}
			case .low:
				testResultMetadata.hoursSinceHighRiskWarningAtTestRegistration = -1
			}
		}
		
		if let checkinRiskCalculationResult = store?.checkinRiskCalculationResult {
			testResultMetadata.checkinRiskLevelAtTestRegistration = checkinRiskCalculationResult.riskLevel
			
			if let mostRecentRiskCalculationDate = checkinRiskCalculationResult.mostRecentDateWithCurrentRiskLevel {
				let daysSinceMostRecentDateAtRiskLevelAtTestRegistration = Calendar.current.dateComponents([.day], from: mostRecentRiskCalculationDate, to: date).day
				testResultMetadata.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration = daysSinceMostRecentDateAtRiskLevelAtTestRegistration
				Log.debug("daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: \(String(describing: daysSinceMostRecentDateAtRiskLevelAtTestRegistration))", log: .ppa)
			} else {
				testResultMetadata.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration = -1
				Log.warning("daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: -1", log: .ppa)
			}
			
			switch checkinRiskCalculationResult.riskLevel {
			case .high:
				if let timeOfRiskChangeToHigh = store?.dateOfConversionToCheckinHighRisk {

				let differenceInHours = Calendar.current.dateComponents([.hour], from: timeOfRiskChangeToHigh, to: date)
				testResultMetadata.hoursSinceCheckinHighRiskWarningAtTestRegistration = differenceInHours.hour
				} else {
					Log.warning("Could not log checkin risk calculation result due to timeOfRiskChangeToHigh is nil", log: .ppa)
				}
			case .low:
				testResultMetadata.hoursSinceCheckinHighRiskWarningAtTestRegistration = -1
			}
		}
		
		// at the end, create the filled new test result metadata.
		store?.testResultMetadata = testResultMetadata
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
				store?.testResultMetadata?.testResult = testResult

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
		case let .submittedWithCheckins(withCheckins):
			store?.keySubmissionMetadata?.submittedWithCheckIns = withCheckins
		case let .lastSubmissionFlowScreen(flowScreen):
			store?.keySubmissionMetadata?.lastSubmissionFlowScreen = flowScreen
		case let .advancedConsentGiven(advanceConsent):
			// this is as per techspecs, this value is false in case TAN submission
			if store?.submittedWithQR == true && advanceConsent == true {
				store?.keySubmissionMetadata?.advancedConsentGiven = advanceConsent
			} else {
				store?.keySubmissionMetadata?.advancedConsentGiven = false
			}
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
		case .setHoursSinceENFHighRiskWarningAtTestRegistration:
			Analytics.setHoursSinceENFHighRiskWarningAtTestRegistration()
		case .setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration:
			Analytics.setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration()
		case .setHoursSinceCheckinHighRiskWarningAtTestRegistration:
			Analytics.setHoursSinceCheckinHighRiskWarningAtTestRegistration()
		case .setDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration:
			Analytics.setDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration()
		}
	}

	private static func setHoursSinceTestResult() {
		guard let testResultReceivedDate = coronaTestService?.pcrTest?.finalTestResultReceivedDate else {
			Log.warning("Could not log hoursSinceTestResult due to testResultReceivedTimeStamp is nil", log: .ppa)
			return
		}

		let diffComponents = Calendar.current.dateComponents([.hour], from: testResultReceivedDate, to: Date())
		store?.keySubmissionMetadata?.hoursSinceTestResult = Int32(diffComponents.hour ?? 0)
	}

	private static func setHoursSinceTestRegistration() {
		guard let registrationDate = coronaTestService?.pcrTest?.registrationDate else {
			Log.warning("Could not log hoursSinceTestRegistration due to testRegistrationDate is nil", log: .ppa)
			return
		}

		let diffComponents = Calendar.current.dateComponents([.hour], from: registrationDate, to: Date())
		store?.keySubmissionMetadata?.hoursSinceTestRegistration = Int32(diffComponents.hour ?? 0)
	}

	private static func setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration() {
		guard let registrationDate = coronaTestService?.pcrTest?.registrationDate else {
			store?.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = -1
			return
		}
		if let mostRecentRiskCalculationDate = store?.enfRiskCalculationResult?.mostRecentDateWithCurrentRiskLevel {
			let daysSinceMostRecentDateAtRiskLevelAtTestRegistration = Calendar.utcCalendar.dateComponents([.day], from: mostRecentRiskCalculationDate, to: registrationDate).day
			store?.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = Int32(daysSinceMostRecentDateAtRiskLevelAtTestRegistration ?? -1)
		} else {
			store?.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = -1
		}
	}

	private static func setHoursSinceENFHighRiskWarningAtTestRegistration() {
		guard let riskLevel = store?.enfRiskCalculationResult?.riskLevel  else {
			Log.warning("Could not log hoursSinceHighRiskWarningAtTestRegistration due to riskLevel is nil", log: .ppa)
			return
		}
		switch riskLevel {
		case .high:
			guard let timeOfRiskChangeToHigh = store?.dateOfConversionToENFHighRisk,
				  let registrationTime = coronaTestService?.pcrTest?.registrationDate else {
				Log.warning("Could not log ENF risk calculation result due to timeOfRiskChangeToHigh is nil", log: .ppa)
				return
			}
			let differenceInHours = Calendar.current.dateComponents([.hour], from: timeOfRiskChangeToHigh, to: registrationTime)
			store?.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration = Int32(differenceInHours.hour ?? -1)
		case .low:
			store?.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration = -1
		}
	}
	
	private static func setDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration() {
		guard let registrationDate = coronaTestService?.pcrTest?.registrationDate else {
			store?.keySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration = -1
			return
		}
		if let mostRecentRiskCalculationDate = store?.checkinRiskCalculationResult?.mostRecentDateWithCurrentRiskLevel {
			let daysSinceMostRecentDateAtRiskLevelAtTestRegistration = Calendar.utcCalendar.dateComponents([.day], from: mostRecentRiskCalculationDate, to: registrationDate).day
			store?.keySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration = Int32(daysSinceMostRecentDateAtRiskLevelAtTestRegistration ?? -1)
		} else {
			store?.keySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration = -1
		}
	}

	private static func setHoursSinceCheckinHighRiskWarningAtTestRegistration() {
		guard let riskLevel = store?.checkinRiskCalculationResult?.riskLevel  else {
			Log.warning("Could not log hoursSinceCheckinHighRiskWarningAtTestRegistration due to riskLevel is nil", log: .ppa)
			return
		}
		switch riskLevel {
		case .high:
			guard let timeOfRiskChangeToHigh = store?.dateOfConversionToCheckinHighRisk,
				  let registrationTime = coronaTestService?.pcrTest?.registrationDate else {
				Log.warning("Could not log Checkin risk calculation result due to timeOfRiskChangeToHigh is nil", log: .ppa)
				return
			}
			let differenceInHours = Calendar.current.dateComponents([.hour], from: timeOfRiskChangeToHigh, to: registrationTime)
			store?.keySubmissionMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration = Int32(differenceInHours.hour ?? -1)
		case .low:
			store?.keySubmissionMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration = -1
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
