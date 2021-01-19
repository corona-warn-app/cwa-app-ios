//
// 🦠 Corona-Warn-App
//

import UIKit

class DeltaOnboardingNewVersionFeatures: DeltaOnboarding {

	let version = "1.6"
	let store: Store
	let supportedCountries: [Country]

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
