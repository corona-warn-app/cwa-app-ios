//
// 🦠 Corona-Warn-App
//

@testable import ENA

extension AppFeatureDeviceTimeCheckDecorator {
	static func mock(
		store: AppFeaturesStoring,
		config: SAP_Internal_V2_ApplicationConfigurationIOS = SAP_Internal_V2_ApplicationConfigurationIOS()
		) -> AppFeatureProviding {
		let featureProvider = AppFeatureProvider(
			appConfigurationProvider: CachedAppConfigurationMock(with: config)
		)
		return AppFeatureDeviceTimeCheckDecorator(featureProvider, store: store)
	}
}

extension AppFeatureUnencryptedEventsDecorator {
	static func mock(
		store: AppFeaturesStoring,
		config: SAP_Internal_V2_ApplicationConfigurationIOS = SAP_Internal_V2_ApplicationConfigurationIOS()
		) -> AppFeatureProviding {
		let featureProvider = AppFeatureProvider(
			appConfigurationProvider: CachedAppConfigurationMock(with: config)
		)
		return AppFeatureUnencryptedEventsDecorator(featureProvider, store: store)
	}
}
