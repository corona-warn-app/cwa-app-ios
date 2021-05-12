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
			didTapConsentButton: { [weak self] in self?.showQRCodeScanner(endOnDismiss: true) },
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
	
	private func showQRCodeScanner(endOnDismiss: Bool) {
		let qrCodeScannerViewController = HealthCertificateQRCodeScannerViewController(
			healthCertificateService: healthCertificateService,
			didScanCertificate: { [weak self] healthCertifiedPerson in
				self?.showHealthCertifiedPerson(healthCertifiedPerson)
				self?.navigationController.dismiss(animated: true)
			},
			dismiss: { [weak self] in
				if endOnDismiss {
					self?.endCoordinator()
				} else {
					self?.navigationController.dismiss(animated: true)
				}
			}
		)

		qrCodeScannerViewController.definesPresentationContext = true

		let qrCodeNavigationController = UINavigationController(rootViewController: qrCodeScannerViewController)
		qrCodeNavigationController.modalPresentationStyle = .fullScreen

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
			didTapRegisterAnotherHealthCertificate: { [weak self] in self?.showQRCodeScanner(endOnDismiss: false) },
			didSwipeToDelete: { [weak self] healthCertificate, confirmDeletion in
				self?.showDeleteAlert(
					submitAction: UIAlertAction(
						title: AppStrings.HealthCertificate.Alert.deleteButton,
						style: .default,
						handler: { _ in
							self?.healthCertificateService.removeHealthCertificate(healthCertificate)
							confirmDeletion()
						}
					)
				)
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: "Weitere Impfung registrieren",
				isPrimaryButtonEnabled: true,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true,
				backgroundColor: .enaColor(for: .backgroundLightGray)
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
						title: AppStrings.HealthCertificate.Alert.deleteButton,
						style: .default,
						handler: { _ in
							self?.healthCertificateService.removeHealthCertificate(healthCertificate)
							self?.navigationController.popToRootViewController(animated: true)
						}
					)
				)
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.HealthCertificate.Details.primaryButton,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true,
				backgroundColor: .enaColor(for: .cellBackground)
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
			title: AppStrings.HealthCertificate.Alert.title,
			message: AppStrings.HealthCertificate.Alert.message,
			preferredStyle: .alert
		)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.HealthCertificate.Alert.cancelButton,
				style: .cancel,
				handler: nil
			)
		)
		alert.addAction(submitAction)
		navigationController.present(alert, animated: true)
	}
	
}
