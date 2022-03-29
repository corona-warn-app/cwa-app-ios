//
// 🦠 Corona-Warn-App
//

import UIKit

// WARNING: Do not rename class name because it is used to identify already presented onboardings. But if you need to, rename it and override the id property of the DeltaOnboarding Protocol and assign the origin id (see DeltaOnboardingProtocols)
class DeltaOnboardingNewVersionFeatures: DeltaOnboarding {

	let version = "2.21"
	let store: Store

	init(store: Store) {
		self.store = store
	}

	func makeViewController() -> DeltaOnboardingViewControllerProtocol {
		let deltaOnboardingViewController = DeltaOnboardingNewVersionFeaturesViewController()

		let navigationController = DeltaOnboardingNavigationController(rootViewController: deltaOnboardingViewController)
		navigationController.navigationBar.prefersLargeTitles = true

		deltaOnboardingViewController.finished = {
			navigationController.finished?()
		}

		return navigationController
	}
}
