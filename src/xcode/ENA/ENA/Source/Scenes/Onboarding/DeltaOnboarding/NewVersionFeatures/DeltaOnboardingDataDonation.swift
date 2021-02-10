////
// 🦠 Corona-Warn-App
//

import UIKit

class DeltaOnboardingDataDonation: DeltaOnboarding {

	let version = "1.13"
	let store: Store

	init(store: Store) {
		self.store = store
	}

	func makeViewController() -> DeltaOnboardingViewControllerProtocol {
		
		let dataDonationViewController = DataDonationViewController(
			presentSelectValueList: { _ in },
			didTapLegal: {}
		)

		let navigationController = DeltaOnboardingNavigationController(rootViewController: dataDonationViewController)
		navigationController.navigationBar.prefersLargeTitles = true

		dataDonationViewController.finished = {
			navigationController.finished?()
		}

		return navigationController
	}
}
