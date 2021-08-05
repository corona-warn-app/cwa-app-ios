////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

// swiftlint:disable file_length
protocol PPAnalyticsSubmitting {
	/// Triggers the submission of all collected analytics data. Only if all checks success, the submission is done. Otherwise, the submission is aborted. The completion calls are passed through to test the component.
	/// ⚠️ This method should ONLY be called by the PPAnalyticsCollector ⚠️
	func triggerSubmitData(ppacToken: PPACToken?, completion: ((Result<Void, PPASError>) -> Void)?)
	
	#if !RELEASE
	/// ONLY FOR TESTING. Triggers for the dev menu a forced submission of the data, whithout any checks.
	/// This method should only be called by the PPAnalyticsCollector
	func forcedSubmitData(completion: @escaping (Result<Void, PPASError>) -> Void)
	/// ONLY FOR TESTING. Return the constructed proto-file message to look into the data we would submit.
	/// This method should only be called by the PPAnalyticsCollector
	func getPPADataMessage() -> SAP_Internal_Ppdd_PPADataIOS
	
	#endif
}

extension PPAnalyticsSubmitting {
	func triggerSubmitData(completion: ((Result<Void, PPASError>) -> Void)?) {
		triggerSubmitData(ppacToken: nil, completion: completion)
	}
}

// swiftlint:disable:next type_body_length
final class PPAnalyticsSubmitter: PPAnalyticsSubmitting {
	
	// MARK: - Init
	
	init(
		store: Store,
		client: Client,
		appConfig: AppConfigurationProviding,
		coronaTestService: CoronaTestService,
		ppacService: PrivacyPreservingAccessControl
	) {
		guard let store = store as? (Store & PPAnalyticsData) else {
			Log.error("I will never submit any analytics data. Could not cast to correct store protocol", log: .ppa)
			fatalError("I will never submit any analytics data. Could not cast to correct store protocol")
		}
		self.store = store
		self.client = client
		self.submissionState = .readyForSubmission
		self.configurationProvider = appConfig
		self.coronaTestService = coronaTestService
		self.ppacService = ppacService
	}
	
	// MARK: - Protocol PPAnalyticsSubmitting
	
	func triggerSubmitData(
		ppacToken: PPACToken? = nil,
		completion: ((Result<Void, PPASError>) -> Void)? = nil
	) {
		Log.info("Analytics submission was triggered. Checking now if we can submit...", log: .ppa)
		
		// Check if a submission is already in progress
		guard submissionState == .readyForSubmission else {
			Log.warning("Analytics submission abort due to submission is already in progress", log: .ppa)
			completion?(.failure(.submissionInProgress))
			return
		}
		
		submissionState = .submissionInProgress
		
		// Check if user has given his consent to collect data
		if userDeclinedAnalyticsCollectionConsent {
			Log.warning("Analytics submission abort due to missing users consent", log: .ppa)
			submissionState = .readyForSubmission
			completion?(.failure(.userConsentError))
			return
		}
		
		Log.debug("PPAnayticsSubmitter requesting AppConfig…", log: .ppa)
		// Sink on the app configuration if something has changed. But do this in background.
		self.configurationProvider.appConfiguration().sink { [ weak self] configuration in
			Log.debug("PPAnayticsSubmitter recieved AppConfig", log: .ppa)
			let ppaConfigData = configuration.privacyPreservingAnalyticsParameters.common
			self?.probabilityToSubmitPPAUsageData = ppaConfigData.probabilityToSubmit
			self?.hoursSinceTestResultToSubmitKeySubmissionMetadata = ppaConfigData.hoursSinceTestResultToSubmitKeySubmissionMetadata
			self?.hoursSinceTestRegistrationToSubmitTestResultMetadata = ppaConfigData.hoursSinceTestRegistrationToSubmitTestResultMetadata
			self?.probabilityToSubmitExposureWindows = ppaConfigData.probabilityToSubmitExposureWindows
			
			guard let strongSelf = self else {
				Log.warning("Analytics submission abort due fail at creating strong self", log: .ppa)
				self?.submissionState = .readyForSubmission
				completion?(.failure(.generalError))
				return
			}
			
			// Check configuration parameter
			let random = Double.random(in: 0...1)
			if random > strongSelf.probabilityToSubmitPPAUsageData {
				Log.warning("Analytics submission abort due to randomness. Random is: \(random), probabilityToSubmit is: \(strongSelf.probabilityToSubmitPPAUsageData)", log: .ppa)
				strongSelf.submissionState = .readyForSubmission
				completion?(.failure(.probibilityError))
				return
			}
			
			// Last submission check
			if strongSelf.submissionWithinLast23Hours {
				Log.warning("Analytics submission abort due to submission last 23 hours", log: .ppa)
				strongSelf.submissionState = .readyForSubmission
				completion?(.failure(.submission23hoursError))
				return
			}
			
			// Onboarding check
			if strongSelf.onboardingCompletedWithinLast24Hours {
				Log.warning("Analytics submission abort due to onboarding completed last 24 hours", log: .ppa)
				strongSelf.submissionState = .readyForSubmission
				completion?(.failure(.onboardingError))
				return
			}
			
			// App Reset check
			if strongSelf.appResetWithinLast24Hours {
				Log.warning("Analytics submission abort due to app resetted last 24 hours", log: .ppa)
				strongSelf.submissionState = .readyForSubmission
				completion?(.failure(.appResetError))
				return
			}

			if let token = ppacToken {
				Log.info("Analytics submission has an injected ppac token.", log: .ppa)
				strongSelf.submitData(with: token, completion: completion)
			} else {
				Log.info("Analytics submission needs to generate new ppac token.", log: .ppa)
				strongSelf.generatePPACAndSubmitData(completion: completion)
			}
		}.store(in: &subscriptions)
	}
	
	#if !RELEASE
	
	func forcedSubmitData(completion: @escaping (Result<Void, PPASError>) -> Void) {
		generatePPACAndSubmitData(
			disableExposureWindowsProbability: true,
			completion: completion
		)
	}
	
	func getPPADataMessage() -> SAP_Internal_Ppdd_PPADataIOS {
		return obtainUsageData(disableExposureWindowsProbability: true)
	}
	
	// These 4 computed properties are only for the developer menu. These properties can only be accessed here or in the collector. Submitter is already injected in the DM, so it is the easiest way to read out these properties and to prevent to open the PPA Store.
	
	var currentENFRiskExposureMetadata: RiskExposureMetadata? {
		return store.currentENFRiskExposureMetadata
	}

	var previousENFRiskExposureMetadata: RiskExposureMetadata? {
		return store.previousENFRiskExposureMetadata
	}
	
	var currentCheckinRiskExposureMetadata: RiskExposureMetadata? {
		return store.currentCheckinRiskExposureMetadata
	}

	var previousCheckinRiskExposureMetadata: RiskExposureMetadata? {
		return store.previousCheckinRiskExposureMetadata
	}
	
	#endif
	
	// MARK: - Private
	
	private let store: (Store & PPAnalyticsData)
	private let client: Client
	private let configurationProvider: AppConfigurationProviding
	private let coronaTestService: CoronaTestService
	private let ppacService: PrivacyPreservingAccessControl
	
	private var submissionState: PPASubmissionState
	private var subscriptions: Set<AnyCancellable> = []
	private var probabilityToSubmitPPAUsageData: Double = 0
	private var hoursSinceTestRegistrationToSubmitTestResultMetadata: Int32 = 0
	private var probabilityToSubmitExposureWindows: Double = 0
	private var hoursSinceTestResultToSubmitKeySubmissionMetadata: Int32 = 0
	
	private var userDeclinedAnalyticsCollectionConsent: Bool {
		return !store.isPrivacyPreservingAnalyticsConsentGiven
	}
	
	private var submissionWithinLast23Hours: Bool {
		guard let lastSubmission = store.lastSubmissionAnalytics,
			  let twentyThreeHoursAgo = Calendar.current.date(byAdding: .hour, value: -23, to: Date()) else {
			return false
		}
		let lastTwentyThreeHours = twentyThreeHoursAgo...Date()
		return lastTwentyThreeHours.contains(lastSubmission)
	}
	
	private var onboardingCompletedWithinLast24Hours: Bool {
		// why the date of acceptedPrivacyNotice? See https://github.com/corona-warn-app/cwa-app-tech-spec/pull/19#discussion_r572826236
		guard let onbaordedDate = store.dateOfAcceptedPrivacyNotice,
			  let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) else {
			return false
		}
		let lastTwentyFourHours = twentyFourHoursAgo...Date()
		return lastTwentyFourHours.contains(onbaordedDate)
	}
	
	private var appResetWithinLast24Hours: Bool {
		guard let lastResetDate = store.lastAppReset,
			  let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) else {
			return false
		}
		let lastTwentyFourHours = twentyFourHoursAgo...Date()
		return lastTwentyFourHours.contains(lastResetDate)
	}

	private func shouldIncludeKeySubmissionMetadata(for type: CoronaTestType) -> Bool {
		/* Conditions for submitting the data:
		submitted is true
		OR
		- differenceBetweenTestResultAndCurrentDateInHours >= hoursSinceTestResultToSubmitKeySubmissionMetadata
		*/

		let isSubmitted: Bool
		let _testResultReceivedDate: Date?

		switch type {
		case .pcr:
			isSubmitted = store.pcrKeySubmissionMetadata?.submitted ?? false
			_testResultReceivedDate = coronaTestService.pcrTest?.finalTestResultReceivedDate
		case .antigen:
			isSubmitted = store.antigenKeySubmissionMetadata?.submitted ?? false
			_testResultReceivedDate = coronaTestService.antigenTest?.finalTestResultReceivedDate
		}

		// if there is no test result time stamp
		guard let testResultReceivedDate = _testResultReceivedDate else {
			return isSubmitted
		}

		var timeDifferenceFulfillsCriteria = false

		let differenceBetweenTestResultAndCurrentDate = Calendar.current.dateComponents([.hour], from: testResultReceivedDate, to: Date())
		if let differenceBetweenTestResultAndCurrentDateInHours = differenceBetweenTestResultAndCurrentDate.hour,
		   differenceBetweenTestResultAndCurrentDateInHours >= hoursSinceTestResultToSubmitKeySubmissionMetadata {
			timeDifferenceFulfillsCriteria = true
		}
		return isSubmitted || timeDifferenceFulfillsCriteria
	}

	private func shouldIncludeTestResultMetadata(for type: CoronaTestType) -> Bool {
		/* Conditions for submitting the data:
		- testResult = positive
		OR
		- testResult = negative
		OR
		- differenceBetweenRegistrationAndCurrentDateInHours "Registration is stored In TestMetadata" >= hoursSinceTestRegistrationToSubmitTestResultMetadata "stored in appConfiguration"
		*/

		let metadata: TestResultMetadata?

		switch type {
		case .pcr:
			metadata = store.pcrTestResultMetadata
		case .antigen:
			metadata = store.antigenTestResultMetadata
		}

		// If for some reason there is no registrationDate we should not submit the testMetadata
		guard let registrationDate = metadata?.testRegistrationDate else {
			return false
		}

		switch metadata?.testResult {
		case .positive, .negative:
			return true
		default:
			break
		}
		let differenceBetweenRegistrationAndCurrentDate = Calendar.current.dateComponents([.hour], from: registrationDate, to: Date())

		if let differenceBetweenRegistrationAndCurrentDateInHours = differenceBetweenRegistrationAndCurrentDate.hour,
		   differenceBetweenRegistrationAndCurrentDateInHours >= hoursSinceTestRegistrationToSubmitTestResultMetadata {
			return true
		}
		return false
	}
	
	private func generatePPACAndSubmitData(disableExposureWindowsProbability: Bool = false, completion: ((Result<Void, PPASError>) -> Void)? = nil) {
		// Submit analytics data with generated ppac token
		ppacService.getPPACTokenEDUS { [weak self] result in
			switch result {
			case let .success(token):
				Log.info("Succesfully created new ppac token to submit analytics data.", log: .ppa)
				self?.submitData(with: token, disableExposureWindowsProbability: disableExposureWindowsProbability, completion: completion)
			case let .failure(error):
				Log.error("Could not submit analytics data due to ppac authorization error", log: .ppa, error: error)
				self?.submissionState = .readyForSubmission
				completion?(.failure(.ppacError(error)))
				return
			}
		}
	}
	
	private func obtainUsageData(disableExposureWindowsProbability: Bool = false) -> SAP_Internal_Ppdd_PPADataIOS {
		Log.info("Obtaining now all usage data for analytics submission...", log: .ppa)
		let exposureRiskMetadata = gatherExposureRiskMetadata()
		let userMetadata = gatherUserMetadata()
		let clientMetadata = gatherClientMetadata()
		let pcrKeySubmissionMetadata = gatherKeySubmissionMetadata(for: .pcr)
		let antigenKeySubmissionMetadata = gatherKeySubmissionMetadata(for: .antigen)
		let pcrTestResultMetadata = gatherTestResultMetadata(for: .pcr)
		let antigenTestResultMetadata = gatherTestResultMetadata(for: .antigen)
		let newExposureWindows = gatherNewExposureWindows()
		
		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = exposureRiskMetadata
			$0.userMetadata = userMetadata
			$0.clientMetadata = clientMetadata
			$0.userMetadata = userMetadata

			var keySubmissionMetadataSet = [SAP_Internal_Ppdd_PPAKeySubmissionMetadata]()
			if shouldIncludeKeySubmissionMetadata(for: .pcr),
			   let pcrKeySubmissionMetadata = pcrKeySubmissionMetadata {
				keySubmissionMetadataSet.append(pcrKeySubmissionMetadata)
			}
			if shouldIncludeKeySubmissionMetadata(for: .antigen),
			   let antigenKeySubmissionMetadata = antigenKeySubmissionMetadata {
				keySubmissionMetadataSet.append(antigenKeySubmissionMetadata)
			}
			$0.keySubmissionMetadataSet = keySubmissionMetadataSet

			var testResultMetadataSet = [SAP_Internal_Ppdd_PPATestResultMetadata]()
			if shouldIncludeTestResultMetadata(for: .pcr) {
				testResultMetadataSet.append(pcrTestResultMetadata)
			}
			if shouldIncludeTestResultMetadata(for: .antigen) {
				testResultMetadataSet.append(antigenTestResultMetadata)
			}
			$0.testResultMetadataSet = testResultMetadataSet

			/*
			Exposure Windows are included in the next submission if:
			- a generated random number between 0 and 1 is lower than or equal the value of Configuration Parameter .probabilityToSubmitExposureWindows.
			- This shall be logged as warning.
			*/
			if disableExposureWindowsProbability {
				$0.newExposureWindows = newExposureWindows
			} else {
				let randomProbability = Double.random(in: 0...1)
				if randomProbability <= probabilityToSubmitExposureWindows {
					$0.newExposureWindows = newExposureWindows
				}
				Log.warning("generated probability to submit New Exposure Windows: \(randomProbability)", log: .ppa)
				Log.warning("configuration probability to submit New Exposure Windows: \(probabilityToSubmitExposureWindows)", log: .ppa)
			}
		}
		
		return payload
	}
	
	private func submitData(with ppacToken: PPACToken, disableExposureWindowsProbability: Bool = false, completion: ((Result<Void, PPASError>) -> Void)? = nil) {
		
		Log.info("All checks passed succesfully to submit ppa. Obtaining usage data right now...", log: .ppa)
		let payload = obtainUsageData(disableExposureWindowsProbability: disableExposureWindowsProbability)
		Log.info("Completed obtaining all usage data for analytics submission. Sending right now to server...", log: .ppa)
		
		var forceApiTokenHeader = false
		#if !RELEASE
		forceApiTokenHeader = store.forceAPITokenAuthorization
		#endif
		
		#if DEBUG
		if isUITesting {
			Log.info("While UI Testing, we do not submit analytics data", log: .ppa)
			submissionState = .readyForSubmission
			completion?(.failure(.generalError))
			return
		}
		#endif
		
		client.submit(
			payload: payload,
			ppacToken: ppacToken,
			isFake: false,
			forceApiTokenHeader: forceApiTokenHeader,
			completion: { [weak self] result in
				switch result {
				case .success:
					Log.info("Analytics data succesfully submitted", log: .ppa)
					// after successful submission, store the current enf risk exposure metadata as the previous one to get the next time a comparison.
					self?.store.previousENFRiskExposureMetadata = self?.store.currentENFRiskExposureMetadata
					self?.store.currentENFRiskExposureMetadata = nil
					// after successful submission, store the current event risk exposure metadata as the previous one to get the next time a comparison.
					self?.store.previousCheckinRiskExposureMetadata = self?.store.currentCheckinRiskExposureMetadata
					self?.store.currentCheckinRiskExposureMetadata = nil
					if let shouldIncludeTestResultMetadata = self?.shouldIncludeTestResultMetadata(for: .pcr),
					   shouldIncludeTestResultMetadata {
						self?.store.pcrTestResultMetadata = nil
					}
					if let shouldIncludeTestResultMetadata = self?.shouldIncludeTestResultMetadata(for: .antigen),
					   shouldIncludeTestResultMetadata {
						self?.store.antigenTestResultMetadata = nil
					}
					if let shouldIncludeKeySubmissionMetadata = self?.shouldIncludeKeySubmissionMetadata(for: .pcr), shouldIncludeKeySubmissionMetadata {
						self?.store.pcrKeySubmissionMetadata = nil
					}
					if let shouldIncludeAntigenKeySubmissionMetadata = self?.shouldIncludeKeySubmissionMetadata(for: .antigen), shouldIncludeAntigenKeySubmissionMetadata {
						self?.store.antigenKeySubmissionMetadata = nil
					}
					self?.store.lastSubmittedPPAData = payload.textFormatString()
					self?.store.exposureWindowsMetadata?.newExposureWindowsQueue.removeAll()
					self?.store.lastSubmissionAnalytics = Date()
					self?.submissionState = .readyForSubmission
					completion?(result)
				case let .failure(error):
					Log.error("Analytics data were not submitted. Error: \(error)", log: .ppa, error: error)
					// tech spec says, we want a fresh state if submission fails
					self?.store.currentENFRiskExposureMetadata = nil
					self?.store.currentCheckinRiskExposureMetadata = nil
					self?.submissionState = .readyForSubmission
					completion?(result)
				}
			}
		)
	}
	
	func gatherExposureRiskMetadata() -> [SAP_Internal_Ppdd_ExposureRiskMetadata] {
		return [SAP_Internal_Ppdd_ExposureRiskMetadata.with {
			// ENF ppa
			if let enfRiskLevel = store.currentENFRiskExposureMetadata?.riskLevel {
				$0.riskLevel = enfRiskLevel.protobuf
			}
			if let enfRiskLevelChangedComparedToPreviousSubmission = store.currentENFRiskExposureMetadata?.riskLevelChangedComparedToPreviousSubmission {
				$0.riskLevelChangedComparedToPreviousSubmission = enfRiskLevelChangedComparedToPreviousSubmission
			}
			if let enfMostRecentDateAtRiskLevel = store.currentENFRiskExposureMetadata?.mostRecentDateAtRiskLevel {
				$0.mostRecentDateAtRiskLevel = formatToUnixTimestamp(for: enfMostRecentDateAtRiskLevel)
			}
			if let enfDateChangedComparedToPreviousSubmission = store.currentENFRiskExposureMetadata?.dateChangedComparedToPreviousSubmission {
				$0.dateChangedComparedToPreviousSubmission = enfDateChangedComparedToPreviousSubmission
			}
			// Checkin ppa
			if let checkinRiskLevel = store.currentCheckinRiskExposureMetadata?.riskLevel {
				$0.ptRiskLevel = checkinRiskLevel.protobuf
			}
			if let checkinRiskLevelChangedComparedToPreviousSubmission = store.currentCheckinRiskExposureMetadata?.riskLevelChangedComparedToPreviousSubmission {
				$0.ptRiskLevelChangedComparedToPreviousSubmission = checkinRiskLevelChangedComparedToPreviousSubmission
			}
			if let checkinMostRecentDateAtRiskLevel = store.currentCheckinRiskExposureMetadata?.mostRecentDateAtRiskLevel {
				$0.ptMostRecentDateAtRiskLevel = formatToUnixTimestamp(for: checkinMostRecentDateAtRiskLevel)
			}
			if let checkinDateChangedComparedToPreviousSubmission = store.currentCheckinRiskExposureMetadata?.dateChangedComparedToPreviousSubmission {
				$0.ptDateChangedComparedToPreviousSubmission = checkinDateChangedComparedToPreviousSubmission
			}
			
		}]
	}
	
	func gatherNewExposureWindows() -> [SAP_Internal_Ppdd_PPANewExposureWindow] {
		guard let exposureWindowsMetadata = store.exposureWindowsMetadata else {
			return []
		}
		let exposureWindowsMetadataProto: [SAP_Internal_Ppdd_PPANewExposureWindow] = exposureWindowsMetadata.newExposureWindowsQueue.map { windowMetadata in
			SAP_Internal_Ppdd_PPANewExposureWindow.with {
				
				$0.normalizedTime = windowMetadata.normalizedTime
				$0.transmissionRiskLevel = Int32(windowMetadata.transmissionRiskLevel)
				$0.exposureWindow = SAP_Internal_Ppdd_PPAExposureWindow.with({ protobufWindow in
					if let infectiousness = windowMetadata.exposureWindow.infectiousness.protobuf {
						protobufWindow.infectiousness = infectiousness
					}
					if let reportType = windowMetadata.exposureWindow.reportType.protobuf {
						protobufWindow.reportType = reportType
					}
					protobufWindow.calibrationConfidence = Int32(windowMetadata.exposureWindow.calibrationConfidence.rawValue)
					protobufWindow.date = Int64(windowMetadata.date.timeIntervalSince1970)
					
					protobufWindow.scanInstances = windowMetadata.exposureWindow.scanInstances.map({ scanInstance in
						SAP_Internal_Ppdd_PPAExposureWindowScanInstance.with { protobufScanInstance in
							protobufScanInstance.secondsSinceLastScan = Int32(scanInstance.secondsSinceLastScan)
							protobufScanInstance.typicalAttenuation = Int32(scanInstance.typicalAttenuation)
							protobufScanInstance.minAttenuation = Int32(scanInstance.minAttenuation)
						}
					})
				})
			}
		}
		return exposureWindowsMetadataProto
	}
	
	func gatherUserMetadata() -> SAP_Internal_Ppdd_PPAUserMetadata {
		// According to the tech spec, grap the user metadata right before the submission. We do not use "Analytics.collect()" here because we are probably already inside this call. So if we would use the call here, we could produce a infinite loop.
		store.userMetadata = store.userData
		guard let storedUserData = store.userMetadata else {
			return SAP_Internal_Ppdd_PPAUserMetadata.with { _ in }
		}
		
		return SAP_Internal_Ppdd_PPAUserMetadata.with {
			if let federalState = storedUserData.federalState {
				$0.federalState = federalState.protobuf
			}
			if let administrativeUnit = storedUserData.administrativeUnit {
				$0.administrativeUnit = Int32(administrativeUnit)
			}
			if let ageGroup = storedUserData.ageGroup {
				$0.ageGroup = ageGroup.protobuf
			}
		}
	}
	
	func gatherClientMetadata() -> SAP_Internal_Ppdd_PPAClientMetadataIOS {
		// According to the tech spec, grap the client metadata right before the submission. We do not use "Analytics.collect()" here because we are probably already inside this call. So if we would use the call here, we could produce a infinite loop.
		let eTag = store.appConfigMetadata?.lastAppConfigETag
		store.clientMetadata = ClientMetadata(etag: eTag)
		
		guard let clientData = store.clientMetadata else {
			return SAP_Internal_Ppdd_PPAClientMetadataIOS.with { _ in }
		}
		
		return SAP_Internal_Ppdd_PPAClientMetadataIOS.with {
			if let cwaVersion = clientData.cwaVersion {
				$0.cwaVersion = cwaVersion.protobuf
			}
			if let eTag = clientData.eTag {
				$0.appConfigEtag = eTag
			}
			$0.iosVersion = clientData.iosVersion.protobuf
		}
	}
	
	// swiftlint:disable:next cyclomatic_complexity
	func gatherKeySubmissionMetadata(for type: CoronaTestType) -> SAP_Internal_Ppdd_PPAKeySubmissionMetadata? {

		let _metadata: KeySubmissionMetadata?
		switch type {
		case .pcr:
			_metadata = store.pcrKeySubmissionMetadata
		case .antigen:
			_metadata = store.antigenKeySubmissionMetadata
		}

		guard let metadata = _metadata else {
			return nil
		}

		return SAP_Internal_Ppdd_PPAKeySubmissionMetadata.with {
			if let submitted = metadata.submitted {
				$0.submitted = submitted
			}
			if let submittedInBackground = metadata.submittedInBackground {
				$0.submittedInBackground = submittedInBackground
			}
			if let submittedAfterCancel = metadata.submittedAfterCancel {
				$0.submittedAfterCancel = submittedAfterCancel
			}
			if let submittedAfterSymptomFlow = metadata.submittedAfterSymptomFlow {
				$0.submittedAfterSymptomFlow = submittedAfterSymptomFlow
			}

			if let advancedConsentGiven = metadata.advancedConsentGiven {
				$0.advancedConsentGiven = advancedConsentGiven
			}
			if let lastSubmissionFlowScreen = metadata.lastSubmissionFlowScreen?.protobuf {
				$0.lastSubmissionFlowScreen = lastSubmissionFlowScreen
			}
			if let hoursSinceTestResult = metadata.hoursSinceTestResult {
				$0.hoursSinceTestResult = hoursSinceTestResult
			}
			if let hoursSinceTestRegistration = metadata.hoursSinceTestRegistration {
				$0.hoursSinceTestRegistration = hoursSinceTestRegistration
			}
			if let daysSinceMostRecentDateAtRiskLevelAtTestRegistration = metadata.daysSinceMostRecentDateAtRiskLevelAtTestRegistration {
				$0.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = daysSinceMostRecentDateAtRiskLevelAtTestRegistration
			}
			if let hoursSinceHighRiskWarningAtTestRegistration = metadata.hoursSinceHighRiskWarningAtTestRegistration {
				$0.hoursSinceHighRiskWarningAtTestRegistration = hoursSinceHighRiskWarningAtTestRegistration
			}
			if let daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration = metadata.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration {
				$0.ptDaysSinceMostRecentDateAtRiskLevelAtTestRegistration = daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration
			}
			if let hoursSinceCheckinHighRiskWarningAtTestRegistration = metadata.hoursSinceCheckinHighRiskWarningAtTestRegistration {
				$0.ptHoursSinceHighRiskWarningAtTestRegistration = hoursSinceCheckinHighRiskWarningAtTestRegistration
			}
			// special handling for the triStateBool
			if let submittedWithCheckins = metadata.submittedWithCheckIns {
				$0.submittedWithCheckIns = submittedWithCheckins ? .tsbTrue : .tsbFalse
			} else {
				$0.submittedWithCheckIns = .tsbFalse
			}
			if let submittedWithTeleTan = metadata.submittedWithTeleTAN {
				$0.submittedWithTeleTan = submittedWithTeleTan
			}
			$0.submittedAfterRapidAntigenTest = metadata.submittedAfterRapidAntigenTest
		}
	}
	
	func gatherTestResultMetadata(for type: CoronaTestType) -> SAP_Internal_Ppdd_PPATestResultMetadata {
		let metadata: TestResultMetadata?

		switch type {
		case .pcr:
			metadata = store.pcrTestResultMetadata
		case .antigen:
			metadata = store.antigenTestResultMetadata
		}

		let resultProtobuf = SAP_Internal_Ppdd_PPATestResultMetadata.with {
			
			if let testResult = metadata?.protobuf {
				$0.testResult = testResult
			}
			if let hoursSinceTestRegistration = metadata?.hoursSinceTestRegistration {
				$0.hoursSinceTestRegistration = Int32(hoursSinceTestRegistration)
			}
			if let enfRiskLevel = metadata?.riskLevelAtTestRegistration?.protobuf {
				$0.riskLevelAtTestRegistration = enfRiskLevel
			}
			if let daysSinceMostRecentDateAtRiskLevelAtTestRegistration = metadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration {
				$0.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = Int32(daysSinceMostRecentDateAtRiskLevelAtTestRegistration)
			}
			if let hoursSinceHighRiskWarningAtTestRegistration = metadata?.hoursSinceHighRiskWarningAtTestRegistration {
				$0.hoursSinceHighRiskWarningAtTestRegistration = Int32(hoursSinceHighRiskWarningAtTestRegistration)
			}
			if let checkinRiskLevel = metadata?.checkinRiskLevelAtTestRegistration?.protobuf {
				$0.ptRiskLevelAtTestRegistration = checkinRiskLevel
			}
			if let daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration = metadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration {
				$0.ptDaysSinceMostRecentDateAtRiskLevelAtTestRegistration = Int32(daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration)
			}
			if let hoursSinceCheckinHighRiskWarningAtTestRegistration = metadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration {
				$0.ptHoursSinceHighRiskWarningAtTestRegistration = Int32(hoursSinceCheckinHighRiskWarningAtTestRegistration)
			}
		}
		return resultProtobuf
	}
	
	private func formatToUnixTimestamp(for date: Date?) -> Int64 {
		guard let date = date else {
			Log.warning("mostRecentDate is nil", log: .ppa)
			return -1
		}
		return Int64(date.timeIntervalSince1970)
	}
}
