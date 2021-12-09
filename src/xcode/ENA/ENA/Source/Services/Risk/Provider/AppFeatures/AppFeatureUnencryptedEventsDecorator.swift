//
// 🦠 Corona-Warn-App
//

#if !RELEASE
/// App Feature provider decorator to read unencrypted event checkins from store (used for the debug menu)
///
class AppFeatureUnencryptedEventsDecorator: AppFeatureProviding {

	// MARK: - Init

	init(
		_ decorator: AppFeatureProviding,
		store: AppFeaturesStoring
	) {
		self.decorator = decorator
		self.store = store
	}

	// MARK: - Protocol AppFeaturesProviding

	func boolValue(for appFeature: SAP_Internal_V2_ApplicationConfigurationIOS.AppFeature) -> Bool {
		guard appFeature == .unencryptedCheckinsEnabled,
			  store.unencryptedCheckinsEnabled else {
			return decorator.boolValue(for: appFeature)
		}

		return true
	}

	func intValue(for appFeature: SAP_Internal_V2_ApplicationConfigurationIOS.AppFeature) -> Int {
		guard appFeature == .unencryptedCheckinsEnabled,
			  store.unencryptedCheckinsEnabled else {
			return decorator.intValue(for: appFeature)
		}

		return 1
	}

	// MARK: - Private

	private let decorator: AppFeatureProviding
	private let store: AppFeaturesStoring

}
#endif
