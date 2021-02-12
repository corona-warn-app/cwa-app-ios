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
		
		weak var navigationController: DeltaOnboardingNavigationController?
		
		let dataDonationViewController = DataDonationViewController(
			store: store,
			presentSelectValueList: { selectValueViewModel in
				let selectValueViewController = SelectValueTableViewController(
					selectValueViewModel,
					dissmiss: {
						navigationController?.dismiss(animated: true)
					})
				let selectValueNavigationController = UINavigationController(rootViewController: selectValueViewController)
				navigationController?.present(selectValueNavigationController, animated: true)
			},
			didTapLegal: {}
		)

		let deltaOnboardingNavigationController = DeltaOnboardingNavigationController(rootViewController: dataDonationViewController)
		deltaOnboardingNavigationController.navigationBar.prefersLargeTitles = true

		dataDonationViewController.finished = {
			deltaOnboardingNavigationController.finished?()
		}

		navigationController = deltaOnboardingNavigationController
		return deltaOnboardingNavigationController
	}
}
