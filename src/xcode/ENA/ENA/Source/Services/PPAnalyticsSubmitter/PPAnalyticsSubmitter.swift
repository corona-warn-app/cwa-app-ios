////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol PPAnalyticsSubmitting {
	/// Triggers the submission of all collected analytics data. Only if all checks success, the submission is done. Otherwise, the submission is aborted. In all cases, NO completion is called.
	func triggerSubmitData()

	#if !RELEASE
	/// ONLY FOR TESTING. Triggers the submission of all collected analytics data. Only if all checks success, the submission is done. Otherwise, the submission is aborted. The completion calls are passed through to test the component.
	func triggerSubmitData(ppacToken: PPACToken?, completion: ((Result<Void, PPASError>) -> Void)?)
	/// ONLY FOR TESTING. Triggers for the dev menu a forced submission of the data, whithout any checks.
	func forcedSubmitData(completion: @escaping (Result<Void, PPASError>) -> Void)
	/// ONLY FOR TESTING. Return the constructed proto-file message to look into the data we would submit.
	func getPPADataMessage() -> SAP_Internal_Ppdd_PPADataIOS
	/// ONLY FOR TESTING. Returns the last submitted data.
	func mostRecentAnalyticsData() -> String?
	#endif
}

final class PPAnalyticsSubmitter: PPAnalyticsSubmitting {

	// MARK: - Init

	init(
		store: Store,
		client: Client,
		appConfig: AppConfigurationProviding
	) {
		self.store = store
		self.client = client
		self.configurationProvider = appConfig
	}

	// MARK: - Protocol PPAnalyticsSubmitting

	func triggerSubmitData() {
		// 0. Check if user has given his consent to collect data
		if userDeclinedAnalyticsCollectionConsent {
			Log.warning("Analytics submission abord due to missing users consent", log: .ppa)
			return
		}

		configurationProvider.appConfiguration().sink { [weak self] configuration in

			guard let self = self else {
				Log.warning("Analytics submission abord due fail at creating strong self", log: .ppa)
				return
			}

			// 1. Check configuration parameter
			if Double.random(in: 0...1) > configuration.privacyPreservingAnalyticsParameters.common.probabilityToSubmit {
				Log.warning("Analytics submission abord due to randomness", log: .ppa)
				return
			}

			// 2. Last submission check
			if self.submissionWithinLast23Hours {
				Log.warning("Analytics submission abord due to submission last 23 hours", log: .ppa)
				return
			}

			// 3a. Onboarding check
			if self.onboardingCompletedWithinLast24Hours {
				Log.warning("Analytics submission abord due to onboarding completed last 24 hours", log: .ppa)
				return
			}

			// 3b. App Reset check
			if self.appResetWithinLast24Hours {
				Log.warning("Analytics submission abord due to app resetted last 24 hours", log: .ppa)
				return
			}

			// 5. obtain usage data
			let payload = self.obtainUsageData()

			// 4. obtain authentication data
			let deviceCheck = PPACDeviceCheck()
			let ppacService = PPACService(store: self.store, deviceCheck: deviceCheck)

			// 6. submit analytics data
			ppacService.getPPACToken { [weak self] result in
				switch result {
				case let .success(token):
					self?.submitData(with: token, for: payload, completion: nil)
				case let .failure(error):
					Log.error("Could not submit analytics data due to ppac authorization error", log: .ppa, error: error)
					return
				}
			}

		}.store(in: &subscriptions)
	}

	#if !RELEASE
	func triggerSubmitData(
		ppacToken: PPACToken?,
		completion: ((Result<Void, PPASError>) -> Void)? = nil
	) {

		// 0. Check if user has given his consent to collect data
		if userDeclinedAnalyticsCollectionConsent {
			Log.warning("Analytics submission abord due to missing users consent", log: .ppa)
			completion?(.failure(.userConsentError))
			return
		}

		configurationProvider.appConfiguration().sink { [weak self] configuration in

			guard let self = self else {
				Log.warning("Analytics submission abord due fail at creating strong self", log: .ppa)
				completion?(.failure(.generalError))
				return
			}

			// 1. Check configuration parameter
			if Double.random(in: 0...1) > configuration.privacyPreservingAnalyticsParameters.common.probabilityToSubmit {
				Log.warning("Analytics submission abord due to randomness", log: .ppa)
				completion?(.failure(.probibilityError))
				return
			}

			// 2. Last submission check
			if self.submissionWithinLast23Hours {
				Log.warning("Analytics submission abord due to submission last 23 hours", log: .ppa)
				completion?(.failure(.submission23hoursError))
				return
			}

			// 3a. Onboarding check
			if self.onboardingCompletedWithinLast24Hours {
				Log.warning("Analytics submission abord due to onboarding completed last 24 hours", log: .ppa)
				completion?(.failure(.onboardingError))
				return
			}

			// 3b. App Reset check
			if self.appResetWithinLast24Hours {
				Log.warning("Analytics submission abord due to app resetted last 24 hours", log: .ppa)
				completion?(.failure(.appResetError))
				return
			}

			// 5. obtain usage data
			let payload = self.obtainUsageData()

			if let token = ppacToken {
				self.submitData(with: token, for: payload, completion: completion)
			} else {
				// 4. obtain authentication data
				let deviceCheck = PPACDeviceCheck()
				let ppacService = PPACService(store: self.store, deviceCheck: deviceCheck)

				// 6. submit analytics data
				ppacService.getPPACToken { [weak self] result in
					switch result {
					case let .success(token):
						self?.submitData(with: token, for: payload, completion: completion)
					case let .failure(error):
						Log.error("Could not submit analytics data due to ppac authorization error", log: .ppa, error: error)
						completion?(.failure(.ppacError))
						return
					}
				}
			}

		}.store(in: &subscriptions)
	}

	func forcedSubmitData(completion: @escaping (Result<Void, PPASError>) -> Void) {
		let payload = obtainUsageData()
		let deviceCheck = PPACDeviceCheck()
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		ppacService.getPPACToken { [weak self] result in
			switch result {
			case let .success(token):
				self?.submitData(with: token, for: payload, completion: completion)
			case let .failure(error):
				Log.error("Could not submit analytics data due to ppac authorization error", log: .ppa, error: error)
				completion(.failure(.ppacError))
				return
			}
		}
	}

	func getPPADataMessage() -> SAP_Internal_Ppdd_PPADataIOS {
		return obtainUsageData()
	}

	func mostRecentAnalyticsData() -> String? {
		return store.lastSubmittedPPAData
	}

	#endif

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let store: Store
	private let client: Client
	private let configurationProvider: AppConfigurationProviding

	private var subscriptions = [AnyCancellable]()

	private var userDeclinedAnalyticsCollectionConsent: Bool {
		return !store.isPrivacyPreservingAnalyticsConsentGiven
	}

	private var submissionWithinLast23Hours: Bool {
		guard let lastSubmission = store.submissionAnalytics,
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

	private func obtainUsageData() -> SAP_Internal_Ppdd_PPADataIOS {

		let exposureRiskMetadata = gatherExposureRiskMetadata()
		// already created for EXPOSUREAPP-4790
		/*
		let newExposureWindows = gatherNewExposureWindows()
		let testResultMetadata = gatherTestResultMetadata()
		let keySubmissionMetadata = gatherKeySubmissionMetadata()
		let clientMetadata = gatherClientMetadata()
		*/
		let userMetadata = gatherUserMetadata()

		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = exposureRiskMetadata
			// already created for EXPOSUREAPP-4790
			/*
			$0.newExposureWindows = newExposureWindows
			$0.testResultMetadataSet = testResultMetadata
			$0.keySubmissionMetadataSet = keySubmissionMetadata
			$0.clientMetadata = clientMetadata
			*/
			$0.userMetadata = userMetadata
		}

		return payload
	}

	private func submitData(with ppacToken: PPACToken, for payload: SAP_Internal_Ppdd_PPADataIOS, completion: ((Result<Void, PPASError>) -> Void)? = nil) {

		var forceApiTokenHeader = false
		#if !RELEASE
		forceApiTokenHeader = store.forceAPITokenAuthorization
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
					self?.store.lastSubmittedPPAData = payload.textFormatString()
					completion?(result)
				case let .failure(error):
					Log.error("Analytics data were not submitted", log: .ppa, error: error)
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

	// already created for EXPOSUREAPP-4790
	/*
	private func gatherNewExposureWindows() -> [SAP_Internal_Ppdd_PPANewExposureWindow] {
	}

	private func gatherTestResultMetadata() -> [SAP_Internal_Ppdd_PPATestResultMetadata] {
	}

	private func gatherKeySubmissionMetadata() -> [SAP_Internal_Ppdd_PPAKeySubmissionMetadata] {
	}

	private func gatherClientMetadata() -> SAP_Internal_Ppdd_PPAClientMetadataIOS {
	}
	*/

	private func gatherUserMetadata() -> SAP_Internal_Ppdd_PPAUserMetadata {
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

	private func formatToUnixTimestamp(for date: Date?) -> Int64 {
		guard let date = date else {
			Log.warning("mostRecentDate is nil", log: .ppa)
			return -1
		}
		return Int64(date.timeIntervalSince1970)
	}
}
