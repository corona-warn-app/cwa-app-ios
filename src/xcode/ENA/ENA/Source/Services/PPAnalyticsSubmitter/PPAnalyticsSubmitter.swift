////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

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

// swiftlint:disable:next type_body_length
final class PPAnalyticsSubmitter: PPAnalyticsSubmitting {
	
	// MARK: - Init
	
	init(
		store: Store,
		client: Client,
		appConfig: AppConfigurationProviding
	) {
		guard let store = store as? (Store & PPAnalyticsData) else {
			Log.error("I will never submit any analytics data. Could not cast to correct store protocol", log: .ppa)
			fatalError("I will never submit any analytics data. Could not cast to correct store protocol")
		}
		self.store = store
		self.client = client
		self.submissionState = .readyForSubmission
		self.configurationProvider = appConfig
		self.dispatchQueueSubmission = DispatchGroup()
	}
	
	// MARK: - Protocol PPAnalyticsSubmitting
	
	func triggerSubmitData(
		ppacToken: PPACToken? = nil,
		completion: ((Result<Void, PPASError>) -> Void)? = nil
	) {
		Log.info("Analytics submission was triggered. Checking now if we can submit...", log: .ppa)
		
		guard submissionState == .readyForSubmission else {
			Log.warning("Analytics submission abord due to submission is already in progress", log: .ppa)
			completion?(.failure(.submissionInProgress))
			return
		}
		
		submissionState = .submissionInProgress
		
		// Sink on the app configuration if something has changed. But do this in background and wait for the result before continue.
		dispatchQueueSubmission.enter()
		self.configurationProvider.appConfiguration().receive(on: DispatchQueue.global(qos: .background).ocombine).sink { [ weak self] configuration in
			let ppaConfigData = configuration.privacyPreservingAnalyticsParameters.common
			self?.probabilityToSubmitPPAUsageData = ppaConfigData.probabilityToSubmit
			self?.hoursSinceTestResultToSubmitKeySubmissionMetadata = ppaConfigData.hoursSinceTestResultToSubmitKeySubmissionMetadata
			self?.hoursSinceTestRegistrationToSubmitTestResultMetadata = ppaConfigData.hoursSinceTestRegistrationToSubmitTestResultMetadata
			self?.probabilityToSubmitExposureWindows = ppaConfigData.probabilityToSubmitExposureWindows
			self?.dispatchQueueSubmission.leave()
		}.store(in: &subscriptions)
		
		// If we have the app config, we continue...
		dispatchQueueSubmission.notify(queue: .global(qos: .background)) { [weak self] in
			guard let strongSelf = self else {
				Log.warning("Analytics submission abord due fail at creating strong self", log: .ppa)
				self?.submissionState = .readyForSubmission
				completion?(.failure(.generalError))
				return
			}
			
			// Check if user has given his consent to collect data
			if strongSelf.userDeclinedAnalyticsCollectionConsent {
				Log.warning("Analytics submission abord due to missing users consent", log: .ppa)
				strongSelf.submissionState = .readyForSubmission
				completion?(.failure(.userConsentError))
				return
			}
			
			// Check configuration parameter
			let random = Double.random(in: 0...1)
			if random > strongSelf.probabilityToSubmitPPAUsageData {
				Log.warning("Analytics submission abord due to randomness. Random is: \(random), probabilityToSubmit is: \(strongSelf.probabilityToSubmitPPAUsageData)", log: .ppa)
				strongSelf.submissionState = .readyForSubmission
				completion?(.failure(.probibilityError))
				return
			}
			
			// Last submission check
			if strongSelf.submissionWithinLast23Hours {
				Log.warning("Analytics submission abord due to submission last 23 hours", log: .ppa)
				strongSelf.submissionState = .readyForSubmission
				completion?(.failure(.submission23hoursError))
				return
			}
			
			// Onboarding check
			if strongSelf.onboardingCompletedWithinLast24Hours {
				Log.warning("Analytics submission abord due to onboarding completed last 24 hours", log: .ppa)
				strongSelf.submissionState = .readyForSubmission
				completion?(.failure(.onboardingError))
				return
			}
			
			// App Reset check
			if strongSelf.appResetWithinLast24Hours {
				Log.warning("Analytics submission abord due to app resetted last 24 hours", log: .ppa)
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
		}
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
	
	#endif
	
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
	private let store: (Store & PPAnalyticsData)
	private let client: Client
	private let configurationProvider: AppConfigurationProviding
	private let dispatchQueueSubmission: DispatchGroup
	
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
	
	private var shouldIncludeKeySubmissionMetadata: Bool {
		/* Conditions for submitting the data:
		submitted is true
		OR
		- differenceBetweenTestResultAndCurrentDateInHours >= hoursSinceTestResultToSubmitKeySubmissionMetadata
		*/
		var isSubmitted = false
		var timeDifferenceFulfilsCriteria = false
		
		// if submitted is true
		if store.keySubmissionMetadata?.submitted == true {
			isSubmitted = true
		} else {
			isSubmitted = false
		}
		
		// if there is no test result time stamp
		guard let resultDateTimeStamp = store.testResultReceivedTimeStamp else {
			return isSubmitted
		}
		
		let timeInterval = TimeInterval(resultDateTimeStamp)
		let testResultDate = Date(timeIntervalSince1970: timeInterval)
		let differenceBetweenTestResultAndCurrentDate = Calendar.current.dateComponents([.hour], from: testResultDate, to: Date())
		if let differenceBetweenTestResultAndCurrentDateInHours = differenceBetweenTestResultAndCurrentDate.hour,
		   differenceBetweenTestResultAndCurrentDateInHours >= hoursSinceTestResultToSubmitKeySubmissionMetadata {
			timeDifferenceFulfilsCriteria = true
		}
		return isSubmitted || timeDifferenceFulfilsCriteria
	}
	
	private var shouldIncludeTestResultMetadata: Bool {
		/* Conditions for submitting the data:
		- testResult = positive
		OR
		- testResult = negative
		OR
		- differenceBetweenRegistrationAndCurrentDateInHours "Registration is stored In TestMetadata" >= hoursSinceTestRegistrationToSubmitTestResultMetadata "stored in appConfiguration"
		*/
		
		// If for some reason there is no registrationDate we should not submit the testMetadata
		guard let registrationDate = store.testResultMetadata?.testRegistrationDate else {
			return false
		}
		
		switch store.testResultMetadata?.testResult {
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
		// Obtain authentication data
		let deviceCheck = PPACDeviceCheck()
		let ppacService = PPACService(store: self.store, deviceCheck: deviceCheck)
		
		// Submit analytics data with generated ppac token
		ppacService.getPPACToken { [weak self] result in
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
		let keySubmissionMetadata = gatherKeySubmissionMetadata()
		let testResultMetadata = gatherTestResultMetadata()
		let newExposureWindows = gatherNewExposureWindows()
		
		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = exposureRiskMetadata
			$0.userMetadata = userMetadata
			$0.clientMetadata = clientMetadata
			$0.userMetadata = userMetadata
			
			if shouldIncludeKeySubmissionMetadata {
				$0.keySubmissionMetadataSet = keySubmissionMetadata
			}
			if shouldIncludeTestResultMetadata {
				$0.testResultMetadataSet = testResultMetadata
			}
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
					// after succesful submission, store the current risk exposure metadata as the previous one to get the next time a comparison.
					self?.store.previousRiskExposureMetadata = self?.store.currentRiskExposureMetadata
					self?.store.currentRiskExposureMetadata = nil
					self?.store.testResultMetadata = nil
					self?.store.keySubmissionMetadata = nil
					self?.store.lastSubmittedPPAData = payload.textFormatString()
					self?.store.exposureWindowsMetadata?.newExposureWindowsQueue.removeAll()
					self?.store.lastSubmissionAnalytics = Date()
					self?.submissionState = .readyForSubmission
					completion?(result)
				case let .failure(error):
					Log.error("Analytics data were not submitted. Error: \(error)", log: .ppa, error: error)
					self?.submissionState = .readyForSubmission
					completion?(result)
				}
			}
		)
	}
	
	private func gatherExposureRiskMetadata() -> [SAP_Internal_Ppdd_ExposureRiskMetadata] {
		guard let storedUsageData = store.currentRiskExposureMetadata else {
			return []
		}
		return [SAP_Internal_Ppdd_ExposureRiskMetadata.with {
			$0.riskLevel = storedUsageData.riskLevel.protobuf
			$0.riskLevelChangedComparedToPreviousSubmission = storedUsageData.riskLevelChangedComparedToPreviousSubmission
			$0.mostRecentDateAtRiskLevel = formatToUnixTimestamp(for: storedUsageData.mostRecentDateAtRiskLevel)
			$0.dateChangedComparedToPreviousSubmission = storedUsageData.dateChangedComparedToPreviousSubmission
		}]
	}
	
	private func gatherNewExposureWindows() -> [SAP_Internal_Ppdd_PPANewExposureWindow] {
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
	
	private func gatherUserMetadata() -> SAP_Internal_Ppdd_PPAUserMetadata {
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
	
	private func gatherClientMetadata() -> SAP_Internal_Ppdd_PPAClientMetadataIOS {
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
	private func gatherKeySubmissionMetadata() -> [SAP_Internal_Ppdd_PPAKeySubmissionMetadata] {
		guard let storedUsageData = store.keySubmissionMetadata else {
			return []
		}
		return [SAP_Internal_Ppdd_PPAKeySubmissionMetadata.with {
			if let submitted = storedUsageData.submitted {
				$0.submitted = submitted
			}
			if let submittedInBackground = storedUsageData.submittedInBackground {
				$0.submittedInBackground = submittedInBackground
			}
			if let submittedAfterCancel = storedUsageData.submittedAfterCancel {
				$0.submittedAfterCancel = submittedAfterCancel
			}
			if let submittedAfterSymptomFlow = storedUsageData.submittedAfterSymptomFlow {
				$0.submittedAfterSymptomFlow = submittedAfterSymptomFlow
			}
			if let advancedConsentGiven = storedUsageData.advancedConsentGiven {
				$0.advancedConsentGiven = advancedConsentGiven
			}
			if let lastSubmissionFlowScreen = storedUsageData.lastSubmissionFlowScreen?.protobuf {
				$0.lastSubmissionFlowScreen = lastSubmissionFlowScreen
			}
			if let hoursSinceTestResult = storedUsageData.hoursSinceTestResult {
				$0.hoursSinceTestResult = hoursSinceTestResult
			}
			if let hoursSinceTestRegistration = storedUsageData.hoursSinceTestRegistration {
				$0.hoursSinceTestRegistration = hoursSinceTestRegistration
			}
			if let daysSinceMostRecentDateAtRiskLevelAtTestRegistration = storedUsageData.daysSinceMostRecentDateAtRiskLevelAtTestRegistration {
				$0.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = daysSinceMostRecentDateAtRiskLevelAtTestRegistration
			}
			if let hoursSinceHighRiskWarningAtTestRegistration = storedUsageData.hoursSinceHighRiskWarningAtTestRegistration {
				$0.hoursSinceHighRiskWarningAtTestRegistration = hoursSinceHighRiskWarningAtTestRegistration
			}
			$0.submittedWithTeleTan = !store.submittedWithQR
		}]
	}
	
	private func gatherTestResultMetadata() -> [SAP_Internal_Ppdd_PPATestResultMetadata] {
		let metadata = store.testResultMetadata
		
		let resultProtobuf = SAP_Internal_Ppdd_PPATestResultMetadata.with {
			
			if let testResult = metadata?.testResult?.protobuf {
				$0.testResult = testResult
			}
			if let hoursSinceTestRegistration = metadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration {
				$0.hoursSinceTestRegistration = Int32(hoursSinceTestRegistration)
			}
			if let riskLevel = metadata?.riskLevelAtTestRegistration?.protobuf {
				$0.riskLevelAtTestRegistration = riskLevel
			}
			if let daysSinceMostRecentDateAtRiskLevelAtTestRegistration = metadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration {
				$0.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = Int32(daysSinceMostRecentDateAtRiskLevelAtTestRegistration)
			}
			if let hoursSinceHighRiskWarningAtTestRegistration = metadata?.hoursSinceHighRiskWarningAtTestRegistration {
				$0.hoursSinceHighRiskWarningAtTestRegistration = Int32(hoursSinceHighRiskWarningAtTestRegistration)
			}
		}
		return [resultProtobuf]
	}
	
	private func formatToUnixTimestamp(for date: Date?) -> Int64 {
		guard let date = date else {
			Log.warning("mostRecentDate is nil", log: .ppa)
			return -1
		}
		return Int64(date.timeIntervalSince1970)
	}
}
