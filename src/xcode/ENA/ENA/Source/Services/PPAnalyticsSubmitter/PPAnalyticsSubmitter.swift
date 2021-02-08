////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol PPAnalyticsSubmitting {
	func triggerSubmitData()
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
		self.probabilityToSubmit = 2

		subscripeAppConfig()
	}

	// MARK: - Protocol PPAnalyticsSubmitting

	func triggerSubmitData() {

		// 1. Check configuration parameter
		guard Double.random(in: 0...1) < probabilityToSubmit else {
			Log.warning("Analytics submission abord due to randomness", log: .ppa)
			return
		}

		// 2. Last submission check
		if submissionWithinLast23Hours {
			Log.warning("Analytics submission abord due to submission last 23 hours", log: .ppa)
			return
		}

		// 3. Onboarding check
		if onboardingCompletedWithinLast24Hours {
			Log.warning("Analytics submission abord due to onboarding completed last 24 hours", log: .ppa)
			return
		}

		// 3. App Reset check
		if appResetWithinLast24Hours {
			Log.warning("Analytics submission abord due to app resetted last 24 hours", log: .ppa)
			return
		}

		// 4. obtain authentication data
		let deviceCheck = PPACDeviceCheck()
		guard let ppacService = try? PPACService(store: store, deviceCheck: deviceCheck) else {
			Log.error("Could not initialize ppac", log: .ppa)
			return
		}

		ppacService.getPPACToken { [weak self] result in
			switch result {
			case let .success(token):

				// 5. submit analytics data
				self?.submitData(with: token)
			case let .failure(error):
				Log.error("Could not submit analytics data due to ppac authorization error", log: .ppa, error: error)
				return
			}
		}
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private var subscriptions = [AnyCancellable]()
	private var probabilityToSubmit: Double

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

	private var ppaUsageData: SAP_Internal_Ppdd_PPADataIOS {
		let exposureRiskMetadataSet = SAP_Internal_Ppdd_ExposureRiskMetadata.with {
			$0.riskLevel = .riskLevelHigh
		}

		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = [exposureRiskMetadataSet]
		}

		return payload
	}

	private func subscripeAppConfig() {
		configurationProvider.appConfiguration().sink { [weak self] configuration in
			self?.probabilityToSubmit = configuration.privacyPreservingAnalyticsParameters.common.probabilityToSubmit
		}.store(in: &subscriptions)
	}

	private func submitData(with ppacToken: PPACToken) {

		var forceApiTokenHeader = false
		#if !RELEASE
		forceApiTokenHeader = store.forceAPITokenAuthorization
		#endif

		// 5. obtain usage data
		let payload = ppaUsageData

		// 6. submit data finally
		client.submit(
			payload: payload,
			ppacToken: ppacToken,
			isFake: false,
			forceApiTokenHeader: forceApiTokenHeader,
			completion: { result in
				switch result {
				case .success:
					Log.info("Analytics data succesfully submitted", log: .ppa)
				case let .failure(error):
					Log.error("Analytics data were not submitted", log: .ppa, error: error)
				}
			}
		)
	}

	private let store: Store
	private let client: Client

	private let configurationProvider: AppConfigurationProviding

}
