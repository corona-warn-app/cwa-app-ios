////
// 🦠 Corona-Warn-App
//

import Foundation

protocol AppFeatureProviding {
	func value(for appFeature: SAP_Internal_V2_ApplicationConfigurationIOS.AppFeature) -> Bool
}

class AppFeatureProvider: AppFeatureProviding {

	// MARK: - Init
	init(
		appConfiguration: AppConfigurationProviding
	) {
		self.appConfiguration = appConfiguration
	}

	// MARK: - Protocol AppFeaturesProviding

	func value(for appFeature: SAP_Internal_V2_ApplicationConfigurationIOS.AppFeature) -> Bool {
		guard let configuration = appConfiguration?.currentAppConfig.value else {
			return false
		}
		let feature = configuration.appFeatures.appFeatures.first {
			$0.label == appFeature.rawValue
		}
		return feature?.value == 1
	}

	// MARK: - Private

	private weak var appConfiguration: AppConfigurationProviding?

}

#if !RELEASE
class AppFeatureProviderDeviceTimeCheckDecorator: AppFeatureProviding {

	init(
		_ decorator: AppFeatureProviding,
		store: AppFeaturesStoring
	) {
		self.decorator = decorator
		self.store = store
	}

	// MARK: - Protocol AppFeaturesProviding

	func value(for appFeature: SAP_Internal_V2_ApplicationConfigurationIOS.AppFeature) -> Bool {
		guard appFeature == .disableDeviceTimeCheck,
			  store.dmKillDeviceTimeCheck else {
			return decorator.value(for: appFeature)
		}
			return true
	}

	// MARK: - Private

	private let decorator: AppFeatureProviding
	private let store: AppFeaturesStoring

}
#endif
