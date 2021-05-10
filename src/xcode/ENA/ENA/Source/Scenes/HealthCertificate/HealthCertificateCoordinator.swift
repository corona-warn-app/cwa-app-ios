////
// 🦠 Corona-Warn-App
//

import UIKit

final class HealthCertificateCoordinator {

	// MARK: - Init

	init(
		parentViewController: UIViewController,
		healthCertificateService: HealthCertificateServiceProviding,
		vaccinationValueSetsProvider: VaccinationValueSetsProvider
	) {
		self.parentViewController = parentViewController
		self.healthCertificateService = healthCertificateService
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
		self.navigationController = DismissHandlingNavigationController()
	}

	// MARK: - Internal

	func start() {
		showConsentScreen()
	}

	func start(with healthCertifiedPerson: HealthCertifiedPerson) {
		showHealthCertifiedPerson(healthCertifiedPerson)
		parentViewController.present(navigationController, animated: true)
	}

	func endCoordinator() {
		parentViewController.dismiss(animated: true)
	}

	// MARK: - Private

	private let parentViewController: UIViewController
	private let navigationController: UINavigationController
	private let healthCertificateService: HealthCertificateServiceProviding
	private let vaccinationValueSetsProvider: VaccinationValueSetsProvider

	private func showConsentScreen() {
		let consentScreen = HealthCertificateConsentViewController(
			didTapConsentButton: { [weak self] in self?.showQRCodeScanner() },
			didTapDataPrivacy: { [weak self] in self?.showDisclaimer() },
			dismiss: { [weak self] in self?.endCoordinator() }
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

	private func showDisclaimer() {
		let htmlDisclaimerViewController = HTMLViewController(model: AppInformationModel.privacyModel)
		htmlDisclaimerViewController.title = AppStrings.AppInformation.privacyTitle
		htmlDisclaimerViewController.isDismissable = false
		if #available(iOS 13.0, *) {
			htmlDisclaimerViewController.isModalInPresentation = true
		}
		navigationController.pushViewController(htmlDisclaimerViewController, animated: true)
	}

	private func showQRCodeScanner() {
		let qrCodeScannerViewController = HealthCertificateQRCodeScannerViewController(
			healthCertificateService: healthCertificateService,
			didScanCertificate: { [weak self] healthCertifiedPerson in
				self?.showHealthCertifiedPerson(healthCertifiedPerson)
				self?.navigationController.dismiss(animated: true)
			}, dismiss: { [weak self] in self?.endCoordinator() }
		)

		let qrCodeNavigationController = UINavigationController(rootViewController: qrCodeScannerViewController)
		navigationController.present(qrCodeNavigationController, animated: true)
	}

	private func showHealthCertifiedPerson(_ healthCertifiedPerson: HealthCertifiedPerson) {
		let healthCertificatePersonViewController = HealthCertifiedPersonViewController(
			healthCertificateService: healthCertificateService,
			healthCertifiedPerson: healthCertifiedPerson,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			dismiss: { [weak self] in self?.endCoordinator() },
			didTapHealthCertificate: { [weak self] healthCertificate in
				self?.showHealthCertificate(
					healthCertifiedPerson: healthCertifiedPerson,
					healthCertificate: healthCertificate
				)
			},
			didTapRegisterAnotherHealthCertificate: { [weak self] in self?.showQRCodeScanner() }
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

		navigationController.pushViewController(topBottomContainerViewController, animated: false)
	}

	private func showHealthCertificate(
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificate: HealthCertificate
	) {
		let healthCertificateViewController = HealthCertificateViewController(
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			dismiss: { [weak self] in self?.endCoordinator() },
			didTapDelete: { [weak self] in
				self?.showDeleteAlert(
					submitAction: UIAlertAction(
						title: "Entfernen",
						style: .default,
						handler: { _ in
							self?.navigationController.popToRootViewController(animated: true)
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
