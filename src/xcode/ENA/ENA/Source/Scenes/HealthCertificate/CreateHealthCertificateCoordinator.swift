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
			showQRCodeScanner()
		}
	}

	func end() {
		self.parentViewController.dismiss(animated: true)
	}

	// MARK: - Private

	private let parentViewController: UIViewController
	private let coordinatorViewModel: CreateHealthCertificateCoordinatorViewModel
	private let navigationController: UINavigationController

	private func showConsetScreem() {
		let consetScreen = HealthCertificateConsentViewController(
			didTapConsetButton: showQRCodeScanner
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

	private func showQRCodeScanner() {
		let qrCodeScannerViewController = HealthCertificateQRCodeScannerViewController(
			didScanCertificate: { payload in
				// get healthCertificatePerson from sercvice here
				self.showHealthCertificatePerson(payload)
			}, dismiss: {
				self.end()
			}
		)

		if !navigationController.viewControllers.isEmpty {
			navigationController.pushViewController(qrCodeScannerViewController, animated: true)
		} else {
			navigationController.pushViewController(qrCodeScannerViewController, animated: false)
			parentViewController.present(navigationController, animated: true)
		}
	}

	// healthCertificatePerson is a string for the moment
	private func showHealthCertificatePerson(_ healthCertificatePerson: String) {
		let consetScreen = HealthCertificatePersonViewController(
			healthCertificatePerson: healthCertificatePerson,
			dismiss: {
				self.end()
			},
			didTapHealtCertificate: {
				Log.debug("didTapHealtCertificate")
			},
			didTapRegisterAnotherHealtCertificate: {
				self.showQRCodeScanner()
			}
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: "Weitere Impfung registrieren",
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

		navigationController.pushViewController(topBottomContainerViewController, animated: true)
	}

	// healthCertificate is a string for the moment
	private func showHealthCertificate(_ healthCertificate: String) {
//		let consetScreen = HealthCertificatePersonViewController(
//			healthCertificatePerson: healthCertificate,
//			dismiss: {
//				self.parentViewController.dismiss(animated: true)
//			},
//			didTapHealtCertificate: {
//				Log.debug("didTapHealtCertificate")
//			},
//			didTapRegisterHealtCertificate: <#T##() -> Void#>)
//
//		let footerViewController = FooterViewController(
//			FooterViewModel(
//				primaryButtonName: "Weitere Impfung registrieren",
//				isPrimaryButtonEnabled: true,
//				isSecondaryButtonEnabled: false,
//				isSecondaryButtonHidden: true,
//				backgroundColor: .enaColor(for: .background)
//			)
//		)
//
//		let topBottomContainerViewController = TopBottomContainerViewController(
//			topController: consetScreen,
//			bottomController: footerViewController
//		)
//
//		navigationController.pushViewController(topBottomContainerViewController, animated: true)
	}

}
