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

		// 1. Check Configuration Parameter
		let random = Double.random(in: 0...1)
		if random > probabilityToSubmit {
			Log.warning("Randomness prevents submitting analytics data", log: .ppa)
			return
		}

		// 2. last submition check:


		// if lastCheck >= 23 hours || lastcheck == nil, proceed

		// 3. onnboarding completed >= 24 hours && app reset >= 24 hours, proceed

		// 4. obtain authentication data
		let deviceCheck = PPACDeviceCheck()
		guard let ppacService = try? PPACService(store: store, deviceCheck: deviceCheck) else {
			Log.error("Could not initialize ppac", log: .ppa)
			return
		}

		ppacService.getPPACToken { [weak self] result in
			switch result {
			case let .success(token):
				self?.submitData(with: token)
			case let .failure(error):
				Log.error("Could not submit analytics data due to ppac error", log: .ppa, error: error)
				return
			}
		}
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private var subscriptions = [AnyCancellable]()
	private var probabilityToSubmit: Double

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
