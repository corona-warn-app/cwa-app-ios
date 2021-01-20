//
// 🦠 Corona-Warn-App
//

import UIKit

class DeltaOnboardingNewVersionFeatures: DeltaOnboarding {

	let version = "1.6"
	let store: Store
	let supportedCountries: [Country]
	
	
	// [KGA] Code kommentieren
	// [kga] Code auf new version features ummünzen
	var isFinished: Bool {
		return store.onboardingVersion.numericGreaterOrEqual(then: version)
	}

	// [KGA] Code kommentieren
	// [kga] Code auf new version features ummünzen
	func finish() {
		store.onboardingVersion = version
	}

	init(store: Store, supportedCountries: [Country]) {
		self.store = store
		self.supportedCountries = supportedCountries
	}

	func makeViewController() -> DeltaOnboardingViewControllerProtocol {
		let deltaOnboardingViewController = DeltaOnboardingNewVersionFeaturesViewController(
			supportedCountries: supportedCountries
		)

		let navigationController = DeltaOnboardingNavigationController(rootViewController: deltaOnboardingViewController)

		deltaOnboardingViewController.finished = {
			navigationController.finished?()
		}

		return navigationController
	}
}
