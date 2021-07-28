//
// 🦠 Corona-Warn-App
//

import OpenCombine

final class ValidityService {

	// MARK: - Init

	init(
		dscListProviding: DSCListProviding,
		healthCertificateService: HealthCertificateService,
		appConfigurationProvider: AppConfigurationProviding
	) {
		self.dscListProviding = dscListProviding
		self.healthCertificateService = healthCertificateService
		self.appConfigurationProvider = appConfigurationProvider

		// we are done with init - now let's start watching for some updates
		self.subscribeAppConfigUpdates()
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let dscListProviding: DSCListProviding
	private let healthCertificateService: HealthCertificateService
	private let appConfigurationProvider: AppConfigurationProviding

	private var subscriptions = Set<AnyCancellable>()
	private var lastKnowAppConfiguration: SAP_Internal_V2_ApplicationConfigurationIOS?

	private func subscribeAppConfigUpdates() {
		// subscribe app config updates
		appConfigurationProvider.currentAppConfig
			.sink { [weak self] configuration in
				// only revalidate state if configuration has changed
				if self?.lastKnowAppConfiguration != configuration {
					self?.lastKnowAppConfiguration = configuration
					self?.updateValidityState()
				}
			}
			.store(in: &subscriptions)
	}

	// call back helper for all different kind of updates
	private func updateValidityState() {
		healthCertificateService.updateValidityStates()
	}

}
