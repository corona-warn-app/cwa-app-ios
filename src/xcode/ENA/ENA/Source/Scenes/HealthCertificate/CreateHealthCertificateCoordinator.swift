////
// 🦠 Corona-Warn-App
//

import UIKit

final class CreateHealthCertificateCoordinator {

	// MARK: - Init

	init(
		parentViewController: UIViewController
	) {
		self.parentViewController = parentViewController
		self.coordinatorViewModel = CreateHealthCertificateCoordinatorViewModel()
		self.navigationController = UINavigationController()
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	func start() {
		if !coordinatorViewModel.hasShownConsetScreem {
			showConsetScreem()
		} else {
			presentQRCodeScanner()
		}
	}

	// MARK: - Private

	private let parentViewController: UIViewController
	private let coordinatorViewModel: CreateHealthCertificateCoordinatorViewModel
	private let navigationController: UINavigationController

	private func showConsetScreem() {

		let consetScreen = HealthCertificateConsentViewController(
			didTapConsetButton: presentQRCodeScanner
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: "Einverstanden",
				isPrimaryButtonEnabled: true,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true,
				backgroundColor: .enaColor(for: .background)
			)
		)

		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: consetScreen,
			bottomController: footerViewController
		)

		// we do not animate here because this alwasy is the first screen
		navigationController.pushViewController(topBottomContainerViewController, animated: false)
		parentViewController.present(navigationController, animated: true)
	}

	private func presentQRCodeScanner() {
		let qrCodeScannerViewController = HealthCertificateQRCodeScannerViewController(
			didScanVaccination: { payload in
				Log.debug("Did scan payload \(payload)")
			}, dismiss: {
				self.parentViewController.dismiss(animated: true)
			}
		)

		if !navigationController.viewControllers.isEmpty {
			navigationController.pushViewController(qrCodeScannerViewController, animated: true)
		} else {
			navigationController.pushViewController(qrCodeScannerViewController, animated: false)
			parentViewController.present(navigationController, animated: true)
		}
	}

}
