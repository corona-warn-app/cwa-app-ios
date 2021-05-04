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
		if !coordinatorViewModel.hasShownConsentScreen {
			showConsentScreen()
		} else {
			showQRCodeScanner()
		}
	}

	func endCoordinator() {
		parentViewController.dismiss(animated: true)
	}

	// MARK: - Private

	private let parentViewController: UIViewController
	private let coordinatorViewModel: CreateHealthCertificateCoordinatorViewModel
	private let navigationController: UINavigationController

	private func showConsentScreen() {
		let consentScreen = HealthCertificateConsentViewController(
			didTapConsentButton: showQRCodeScanner,
			dismiss: endCoordinator
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
			topController: consentScreen,
			bottomController: footerViewController
		)

		// we do not animate here because this always is the first screen
		navigationController.pushViewController(topBottomContainerViewController, animated: false)
		parentViewController.present(navigationController, animated: true)
	}

	private func showQRCodeScanner() {
		let qrCodeScannerViewController = HealthCertificateQRCodeScannerViewController(
			didScanCertificate: { payload in
				// get healthCertificatePerson from sercvice here
				self.showHealthCertificatePerson(payload, animated: false)
				self.navigationController.dismiss(animated: true)
			}, dismiss: endCoordinator
		)

		let qrCodeNavigationController = UINavigationController(rootViewController: qrCodeScannerViewController)
		navigationController.present(qrCodeNavigationController, animated: true)
	}

	// healthCertificatePerson is a string for the moment
	private func showHealthCertificatePerson(_ healthCertificatePerson: String, animated: Bool) {
		let healthCertificatePersonViewController = HealthCertifiedPersonViewController(
			healthCertificatePerson: healthCertificatePerson,
			dismiss: endCoordinator,
			didTapHealthCertificate: showHealthCertificate,
			didTapRegisterAnotherHealthCertificate: showQRCodeScanner
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
			topController: healthCertificatePersonViewController,
			bottomController: footerViewController
		)

		navigationController.pushViewController(topBottomContainerViewController, animated: animated)
	}

	// healthCertificate is a string for the moment
	private func showHealthCertificate(_ healthCertificate: String) {
		let healthCertificateViewController = HealthCertificateViewController(
			healthCertificate: healthCertificate,
			dismiss: {
				self.endCoordinator()
			},
			didTapDelete: {
				self.showDeleteAlert(
					submitAction: UIAlertAction(
						title: "Entfernen",
						style: .default,
						handler: { _ in
							self.navigationController.popToRootViewController(animated: true)
						}
					)
				)
			}
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: "Impfzertifikat entfernen",
				isPrimaryButtonEnabled: true,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true,
				backgroundColor: .enaColor(for: .background)
			)
		)

		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: healthCertificateViewController,
			bottomController: footerViewController
		)
		navigationController.pushViewController(topBottomContainerViewController, animated: true)
	}

	private func showDeleteAlert(submitAction: UIAlertAction) {
		let alert = UIAlertController(
			title: "Wollen Sie das Impfzertifikat wirklich entfernen?",
			message: "Wenn Sie das Impfzertifikat entfernen, kann die App die Impfung nicht mehr für die Prüfung Ihres Impfstatus berücksichtigen.",
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
		alert.addAction(submitAction)
		navigationController.present(alert, animated: true)
	}

}
