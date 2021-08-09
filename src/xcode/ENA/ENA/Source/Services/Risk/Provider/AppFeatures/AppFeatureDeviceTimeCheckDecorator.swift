//
// 🦠 Corona-Warn-App
//

#if !RELEASE
/// App Feature provider decorator to read device time check from store (used for the debug menu)
///
class AppFeatureDeviceTimeCheckDecorator: AppFeatureProviding {

	// MARK: - Init

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

	// mock for testing
	static func mock(
		store: AppFeaturesStoring & AppConfigCaching & DeviceTimeCheckStoring,
		config: SAP_Internal_V2_ApplicationConfigurationIOS = SAP_Internal_V2_ApplicationConfigurationIOS()
		) -> AppFeatureProviding {
		let featureProvider = AppFeatureProvider(
			appConfigurationProvider: CachedAppConfigurationMock(with: config, store: store)
		)
		return AppFeatureDeviceTimeCheckDecorator(featureProvider, store: store)
	}

}
#endif
