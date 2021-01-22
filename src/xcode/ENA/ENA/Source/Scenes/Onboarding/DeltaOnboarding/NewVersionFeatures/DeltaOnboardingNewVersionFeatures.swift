//
// 🦠 Corona-Warn-App
//

import UIKit

class DeltaOnboardingNewVersionFeatures: DeltaOnboarding {

	let version = "1.12"
	// [KGA] Code cleanup
//	let version = Bundle.main.appVersion
	let store: Store
	
//	/// Overwrites DeltaOnboarding protocol default isFinished to use 'store.newVersionFeaturesShowVersion' for boolean check
//	var isFinished: Bool {
//		return store.newVersionFeaturesShownForVersion.numericGreaterOrEqual(then: version)
//	}
//
//	/// Overwrites DeltaOnboarding protocol default isFinished to use 'store.newVersionFeaturesShownForVersion' for boolean check
//	func finish() {
//		store.newVersionFeaturesShownForVersion = version
//	}

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
