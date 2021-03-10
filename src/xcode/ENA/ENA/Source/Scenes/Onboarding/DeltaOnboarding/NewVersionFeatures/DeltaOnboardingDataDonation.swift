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

		let dataDonationViewModel = DefaultDataDonationViewModel(
			store: store,
			presentSelectValueList: { selectValueViewModel in
				let selectValueViewController = SelectValueTableViewController(
					selectValueViewModel,
					dismiss: {
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

		let dataDonationViewController = DataDonationViewController(viewModel: dataDonationViewModel)

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.DataDonation.Info.buttonOK,
			secondaryButtonName: AppStrings.DataDonation.Info.buttonNOK,
			isPrimaryButtonEnabled: true,
			isSecondaryButtonEnabled: true,
			isPrimaryButtonHidden: false,
			isSecondaryButtonHidden: false
		)

		let containerViewController = TopBottomContainerViewController(
			topController: dataDonationViewController,
			bottomController: FooterViewController(
				footerViewModel,
				didTapPrimaryButton: {
					dataDonationViewModel.save(consentGiven: true)
					dataDonationViewController.finished?()
				},
				didTapSecondaryButton: {
					dataDonationViewModel.save(consentGiven: false)
					dataDonationViewController.finished?()
				}),
			bottomHeight: 140.0)

		let deltaOnboardingNavigationController = DeltaOnboardingNavigationController(rootViewController: containerViewController)
		deltaOnboardingNavigationController.navigationBar.prefersLargeTitles = true

		dataDonationViewController.finished = {
			deltaOnboardingNavigationController.finished?()
		}

		navigationController = deltaOnboardingNavigationController
		return deltaOnboardingNavigationController
	}
}
