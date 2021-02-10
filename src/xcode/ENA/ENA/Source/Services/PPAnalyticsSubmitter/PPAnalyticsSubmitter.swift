////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol PPAnalyticsSubmitting {
	/// Triggers the submission of all collected analytics data. Only if all checks success, the submission is done. Otherwise, the submission is aborted. In all cases, NO completion is called.
	func triggerSubmitData()

	/// ONLY FOR TESTING. Triggers the submission of all collected analytics data. Only if all checks success, the submission is done. Otherwise, the submission is aborted. The completion calls are passed through to test the component.
	func triggerSubmitData(ppacToken: PPACToken?, completion: ((Result<Void, PPASError>) -> Void)?)

	#if !RELEASE
	// ONLY FOR TESTING. Triggers for the dev menu a forced submission of the data, whithout any checks.
	func forcedSubmitData(completion: @escaping (Result<Void, PPASError>) -> Void)
	// ONLY FOR TESTING. Return the constructed proto-file message to look into the data we would submit.
	func getPPADataMessage() -> SAP_Internal_Ppdd_PPADataIOS
	// ONLY FOR TESTING. Returns the last submitted data.
	func lastSubmittedDataMessage() -> String?
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
		triggerSubmitData(ppacToken: nil, completion: nil)
	}

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
				guard let ppacService = try? PPACService(store: self.store, deviceCheck: deviceCheck) else {
					Log.error("Analytics submission abord due to error at initializing ppac", log: .ppa)
					completion?(.failure(.ppacError))
					return
				}

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

	#if !RELEASE
	func forcedSubmitData(completion: @escaping (Result<Void, PPASError>) -> Void) {
		let payload = self.obtainUsageData()

		let deviceCheck = PPACDeviceCheck()
		guard let ppacService = try? PPACService(store: self.store, deviceCheck: deviceCheck) else {
			Log.error("Analytics submission abord due to error at initializing ppac", log: .ppa)
			completion(.failure(.ppacError))
			return
		}

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

	#endif

	func lastSubmittedDataMessage() -> String? {
		return store.lastSubmittedPPAData
	}


	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let store: Store
	private let client: Client
	private let configurationProvider: AppConfigurationProviding

	private var subscriptions = [AnyCancellable]()

	private var userDeclinedAnalyticsCollectionConsent: Bool {
		return !store.privacyPreservingAnalyticsConsentAccept
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
		guard let onbaordedDate = store.onboardedDate,
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
			$0.riskLevel = convertToProto(storedUsageData.riskLevel)
			$0.riskLevelChangedComparedToPreviousSubmission = storedUsageData.riskLevelChangedComparedToPreviousSubmission
			$0.mostRecentDateAtRiskLevel = convertToProto(for: storedUsageData.mostRecentDateAtRiskLevel)
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
			$0.federalState = convertToProto(storedUserData.federalState)
			$0.administrativeUnit = Int32(storedUserData.administrativeUnit)
			$0.ageGroup = convertToProto(storedUserData.ageGroup)
		}
	}

	// TODO: Make as extenions to the corresponding files

	private func convertToProto(_ riskLevel: RiskLevel) -> SAP_Internal_Ppdd_PPARiskLevel {
		switch riskLevel {
		case .low:
			return .riskLevelLow
		case .high:
			return .riskLevelHigh
		}
	}

	private func convertToProto(for date: Date?) -> Int64 {
		guard let date = date else {
			return -1
		}
		let utcDataFormatter = ISO8601DateFormatter()
		utcDataFormatter.formatOptions = [.withFullDate]

		guard let utcDate = utcDataFormatter.date(from: utcDataFormatter.string(from: date)) else {
			Log.warning("Trouble with converting date to utc midnight date", log: .ppa)
			return Int64(date.timeIntervalSince1970)
		}
		return Int64(utcDate.timeIntervalSince1970)
	}

	private func convertToProto(_ ageGroup: AgeGroup) -> SAP_Internal_Ppdd_PPAAgeGroup {
		switch ageGroup {
		case .ageBelow29:
			return .ageGroup0To29
		case .ageBetween30And59:
			return .ageGroup30To59
		case .age60OrAbove:
			return .ageGroupFrom60
		}
	}

	// swiftlint:disable cyclomatic_complexity
	private func convertToProto(_ federalState: FederalStateName) -> SAP_Internal_Ppdd_PPAFederalState {
		switch federalState {
		case .badenWürttemberg:
			return .federalStateBw
		case .bayern:
			return .federalStateBy
		case .berlin:
			return .federalStateBe
		case .brandenburg:
			return .federalStateBb
		case .bremen:
			return .federalStateHb
		case .hamburg:
			return .federalStateHh
		case .hessen:
			return .federalStateHe
		case .mecklenburgVorpommern:
			return .federalStateMv
		case .niedersachsen:
			return .federalStateNi
		case .nordrheinWestfalen:
			return .federalStateNrw
		case .rheinlandPfalz:
			return .federalStateRp
		case .saarland:
			return .federalStateSl
		case .sachsen:
			return .federalStateSn
		case .sachsenAnhalt:
			return .federalStateSt
		case .schleswigHolstein:
			return .federalStateSh
		case .thüringen:
			return .federalStateTh
		}
	}
}
