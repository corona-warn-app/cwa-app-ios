////
// 🦠 Corona-Warn-App
//

import UIKit

typealias Analytics = PPAnalyticsCollector

/// To avoid that someone instantiate this, we made a enum. This collects the analytics data, makes in some cases some calculations and to save it to the database, to load it from the database, to remove every analytics data from the store. This enum also triggers a submission and grants that nothing can be logged if the user did not give his consent.
enum PPAnalyticsCollector {

	// MARK: - Internal

	/// Setup Analytics for regular use. We expect here a secure store.
	static func setup(
		store: Store,
		coronaTestService: CoronaTestService,
		submitter: PPAnalyticsSubmitting,
		testResultCollector: PPAAnalyticsTestResultCollector,
		submissionCollector: PPAAnalyticsSubmissionCollector
	) {
		// We put the PPAnalyticsData protocol and its implementation in a separate file because this protocol is only used by the collector. And only the collector should use it!
		// This way we avoid the direct access of analytics data at other places over the store.
		guard let store = store as? (Store & PPAnalyticsData) else {
			Log.error("I will never submit any analytics data. Could not cast to correct store protocol", log: .ppa)
			fatalError("I will never submit any analytics data. Could not cast to correct store protocol")
		}

		PPAnalyticsCollector.store = store
		PPAnalyticsCollector.coronaTestService = coronaTestService
		PPAnalyticsCollector.submitter = submitter
		PPAnalyticsCollector.testResultCollector = testResultCollector
		PPAnalyticsCollector.submissionCollector = submissionCollector
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
			submissionCollector?.logKeySubmissionMetadata(keySubmissionMetadata)
		case let .exposureWindowsMetadata(exposureWindowsMetadata):
			Analytics.logExposureWindowsMetadata(exposureWindowsMetadata)
		case let .submissionMetadata(submissionMetadata):
			Analytics.logSubmissionMetadata(submissionMetadata)
		}
		
		// UIApplication.shared does not to seem thread safe, so lets go to main
		DispatchQueue.main.async {
			// Only trigger the submission if the app is in foreground (Exposure-9484). For background, the submission is triggered explicitly.
			if UIApplication.shared.applicationState == .active {
				// At the end, try to submit the data. In the submitter are all the checks that we do not submit the data too often.
				Log.info("Triggering submission after collecting new PPA data", log: .ppa)
				Analytics.triggerAnalyticsSubmission()
			}
		}

	}

	/// This removes all stored analytics data that we collected.
	static func deleteAnalyticsData() {
		store?.currentENFRiskExposureMetadata = nil
		store?.previousENFRiskExposureMetadata = nil
		store?.currentCheckinRiskExposureMetadata = nil
		store?.previousCheckinRiskExposureMetadata = nil
		store?.userMetadata = nil
		store?.lastSubmittedPPAData = nil
		store?.lastAppReset = nil
		store?.lastSubmissionAnalytics = nil
		store?.clientMetadata = nil
		store?.pcrTestResultMetadata = nil
		store?.antigenTestResultMetadata = nil
		store?.pcrKeySubmissionMetadata = nil
		store?.antigenKeySubmissionMetadata = nil
		store?.exposureWindowsMetadata = nil
		store?.currentExposureWindows = nil
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
	private static var submitter: PPAnalyticsSubmitting?
	private static var testResultCollector: PPAAnalyticsTestResultCollector?
	private static var submissionCollector: PPAAnalyticsSubmissionCollector?

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
		riskLevelChangedComparedToPreviousSubmission = riskLevel != previousRiskLevel && previousRiskLevel != nil
		
		// If mostRecentDateAtRiskLevel is nil, set to false. Otherwise, change it when it changed compared to previous submission.
		dateChangedComparedToPreviousSubmission = mostRecentDateWithCurrentRiskLevel != previousMostRecentDateWithCurrentRiskLevel && previousMostRecentDateWithCurrentRiskLevel != nil
		
		guard let mostRecentDate = mostRecentDateWithCurrentRiskLevel else {
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
			mostRecentDateAtRiskLevel: mostRecentDate,
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
		riskLevelChangedComparedToPreviousSubmission = riskLevel != previousRiskLevel && previousRiskLevel != nil

		// If mostRecentDateAtRiskLevel is nil, set to false. Otherwise, change it when it changed compared to previous submission.
		dateChangedComparedToPreviousSubmission = mostRecentDateWithCurrentRiskLevel != previousMostRecentDateWithCurrentRiskLevel && previousMostRecentDateWithCurrentRiskLevel != nil

		guard let mostRecentDate = mostRecentDateWithCurrentRiskLevel else {
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
			mostRecentDateAtRiskLevel: mostRecentDate,
			dateChangedComparedToPreviousSubmission: dateChangedComparedToPreviousSubmission
		)
		store?.currentCheckinRiskExposureMetadata = newRiskExposureMetadata
		
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

		if let store = store, let coronaTestService = coronaTestService {
			let submissionCollector = PPAAnalyticsSubmissionCollector(
				store: store,
				coronaTestService: coronaTestService
			)
			PPAnalyticsCollector.submissionCollector = submissionCollector
		}
	}

	/// ONLY FOR TESTING. Returns the last successful submitted data.
	static func mostRecentAnalyticsData() -> String? {
		return store?.lastSubmittedPPAData
	}

	/// ONLY FOR TESTING. Return the constructed proto-file message to look into the data we have collected so far.
	static func getPPADataMessage() -> SAP_Internal_Ppdd_PPADataIOS? {
		guard let submitter = submitter else {
			Log.warning("I cannot get actual analytics data. Perhaps I am a mock or setup was not called correctly?")
			return nil
		}
		return submitter.getPPADataMessage()
	}

	/// ONLY FOR TESTING. Triggers for the dev menu a forced submission of the data, without any checks.
	static func forcedAnalyticsSubmission(completion: @escaping (Result<Void, PPASError>) -> Void) {
		guard let submitter = submitter else {
			Log.warning("I cannot trigger a forced submission. Perhaps I am a mock or setup was not called correctly?")
			return completion(.failure(.generalError))
		}
		return submitter.forcedSubmitData(completion: completion)
	}

	#endif
}
