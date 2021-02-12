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
		guard let url = Bundle.main.url(forResource: "ppdd-ppa-administrative-unit-set-ua-approved", withExtension: "json") else {
			preconditionFailure("missing json file")
		}

		weak var navigationController: DeltaOnboardingNavigationController?

		let viewModel = DefaultDataDonationViewModel(
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
			datadonationModel: DataDonationModel(
				store: store,
				jsonFileURL: url
			)
		)

		let dataDonationViewController = DataDonationViewController(
			viewModel: viewModel,
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
