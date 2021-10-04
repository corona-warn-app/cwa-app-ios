//
// 🦠 Corona-Warn-App
//

import UIKit

// WARNING: Do not rename class name because it is used to identify already presented onboardings. But if you need to, rename it and override the id property of the DeltaOnboarding Protocol and assign the origin class name
class DeltaOnboardingCrossCountrySupport: DeltaOnboarding {

	let version = "1.5"
	let store: Store
	let supportedCountries: [Country]

	// Needed after renaming class name but to identify saved old onboardings out there.
	var id = "DeltaOnboardingV15"

	init(store: Store, supportedCountries: [Country]) {
		self.store = store
		self.supportedCountries = supportedCountries
	}

	func makeViewController() -> DeltaOnboardingViewControllerProtocol {
		let deltaOnboardingViewController = DeltaOnboardingCrossCountrySupportViewController(
			supportedCountries: supportedCountries
		)

		let navigationController = DeltaOnboardingNavigationController(rootViewController: deltaOnboardingViewController)

		deltaOnboardingViewController.finished = {
			navigationController.finished?()
		}

		return navigationController
	}
}
