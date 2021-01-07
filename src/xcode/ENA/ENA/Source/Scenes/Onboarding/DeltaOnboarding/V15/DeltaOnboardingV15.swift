//
// 🦠 Corona-Warn-App
//

import UIKit

class DeltaOnboardingV15: DeltaOnboarding {

	let version = "1.5"
	let store: Store
	let supportedCountries: [Country]

	init(store: Store, supportedCountries: [Country]) {
		self.store = store
		self.supportedCountries = supportedCountries
	}

	func makeViewController() -> DeltaOnboardingViewControllerProtocol {
		let deltaOnboardingViewController = DeltaOnboardingV15ViewController(
			supportedCountries: supportedCountries
		)

		let navigationController = DeltaOnboardingNavigationController(rootViewController: deltaOnboardingViewController)

		deltaOnboardingViewController.finished = {
			navigationController.finished?()
		}

		return navigationController
	}
}
