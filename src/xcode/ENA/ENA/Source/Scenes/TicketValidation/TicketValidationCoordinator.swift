//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class TicketValidationCoordinator {
	
	// MARK: - Init
	
	init(
		parentViewController: UIViewController,
		healthCertificateService: HealthCertificateService
	) {
		self.parentViewController = parentViewController
		self.healthCertificateService = healthCertificateService
	}
	
	// MARK: - Internal

	func start(ticketValidation: TicketValidating) {
		self.ticketValidation = ticketValidation

		navigationController = DismissHandlingNavigationController(
			rootViewController: firstConsentScreen,
			transparent: true
		)
		parentViewController.present(navigationController, animated: true)
	}
	
	// MARK: - Private
	
	private weak var parentViewController: UIViewController!
	private var navigationController: UINavigationController!
	private var ticketValidation: TicketValidating!
	private var healthCertificateService: HealthCertificateService

	private var firstConsentScreen: UIViewController {
		let firstConsentViewController = FirstTicketValidationConsentViewController(
			viewModel: FirstTicketValidationConsentViewModel(
				serviceProvider: ticketValidation.serviceProvider,
				subject: ticketValidation.subject,
				onDataPrivacyTap: {
					self.showDataPrivacy()
				}
			),
			onPrimaryButtonTap: { [weak self] isLoading in
				isLoading(true)
                
				self?.showCertificateSelectionScreen()
				
				self?.ticketValidation.grantFirstConsent { result in
					isLoading(false)

					switch result {
					case .success:
						self?.showCertificateSelectionScreen()
					case .failure(let error):
						self?.showErrorAlert(error: error)
					}
				}
			},
			onDismiss: {
				self.showDismissAlert()
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.TicketValidation.FirstConsent.primaryButtonTitle,
				secondaryButtonName: AppStrings.TicketValidation.FirstConsent.secondaryButtonTitle,
				isSecondaryButtonEnabled: true,
				isPrimaryButtonHidden: false,
				isSecondaryButtonHidden: false
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: firstConsentViewController,
			bottomController: footerViewController
		)
		
		return topBottomContainerViewController
	}

	private func showDataPrivacy() {
		let detailViewController = HTMLViewController(model: AppInformationModel.privacyModel)
		detailViewController.title = AppStrings.AppInformation.privacyTitle
		detailViewController.isDismissable = false
		if #available(iOS 13.0, *) {
			detailViewController.isModalInPresentation = true
		}

		navigationController.pushViewController(detailViewController, animated: true)
	}

	private func showCertificateSelectionScreen() {
		let certificateSelectionViewController = TicketValidationCertificateSelectionViewController(
			viewModel: TicketValidationCertificateSelectionViewModel(
				serviceProviderRequirementsDescription: "Impfzertifikat, Genesenenzertifikat, Schnelltest-Testzertifikat, PCR-Testzertifikat Geburtsdatum: 1989-12-12 SCHNEIDER<<ANDREA",
				ticketValidationCertificateSelectionState: .noSuitableCertificate
			),
			onDismiss: {
				self.showDismissAlert()
			}
		)
		
		if #available(iOS 13.0, *) {
			certificateSelectionViewController.isModalInPresentation = true
		}
		
		navigationController.pushViewController(certificateSelectionViewController, animated: true)
	}

	private func showErrorAlert(error: TicketValidationError) {

	}

	private func showDismissAlert() {
		let alert = UIAlertController(
			title: AppStrings.TicketValidation.CancelAlert.title,
			message: AppStrings.TicketValidation.CancelAlert.message,
			preferredStyle: .alert
		)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.TicketValidation.CancelAlert.continueButtonTitle,
				style: .default
			)
		)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.TicketValidation.CancelAlert.cancelButtonTitle,
				style: .cancel,
				handler: { [weak self] _ in
					self?.navigationController.dismiss(animated: true)
				}
			)
		)

		navigationController.present(alert, animated: true)
	}

}
