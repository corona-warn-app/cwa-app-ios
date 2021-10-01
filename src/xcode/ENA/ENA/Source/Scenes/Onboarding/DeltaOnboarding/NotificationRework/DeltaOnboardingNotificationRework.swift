////
// 🦠 Corona-Warn-App
//

import UIKit

class DeltaOnboardingNotificationRework: DeltaOnboarding {
		
	// MARK: - Protocol DeltaOnboarding
		
	let version = "2.120"
	let store: Store

	init(store: Store) {
		self.store = store
	}

	func makeViewController() -> DeltaOnboardingViewControllerProtocol {
		let deltaOnboardingViewController = DeltaOnboardingNotificationReworkViewController()

		let navigationController = DeltaOnboardingNavigationController(rootViewController: deltaOnboardingViewController)

		deltaOnboardingViewController.finished = {
			navigationController.finished?()
		}

		return navigationController
	}
}
