//
// 🦠 Corona-Warn-App
//

import UIKit

class DeltaOnboardingNewVersionFeatures: DeltaOnboarding {

	let version = Bundle.main.appVersion
	let store: Store
	let supportedCountries: [Country]
	
	
	/// Overwrites DeltaOnboarding isFinished to use 'store.newVersionFeaturesShowVersion' for boolean check
	var isFinished: Bool {
		return store.newVersionFeaturesShownForVersion.numericGreaterOrEqual(then: version)
	}

	/// Overwrites DeltaOnboarding isFinished to use 'store.newVersionFeaturesShownForVersion' for boolean check
	func finish() {
		store.newVersionFeaturesShownForVersion = version
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
