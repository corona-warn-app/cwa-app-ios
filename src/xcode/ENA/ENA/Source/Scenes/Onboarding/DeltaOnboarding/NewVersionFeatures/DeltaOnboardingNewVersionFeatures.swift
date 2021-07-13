//
// 🦠 Corona-Warn-App
//

import UIKit

class DeltaOnboardingNewVersionFeatures: DeltaOnboarding {

	let version = "2.6"
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
