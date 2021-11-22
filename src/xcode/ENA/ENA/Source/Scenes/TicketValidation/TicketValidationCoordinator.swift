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
				serviceProvider: ticketValidation.initializationData.serviceProvider,
				subject: ticketValidation.initializationData.subject,
				onDataPrivacyTap: {
					self.showDataPrivacy()
				}
			),
			onPrimaryButtonTap: { [weak self] isLoading in
				isLoading(true)

				self?.ticketValidation.grantFirstConsent { result in
					DispatchQueue.main.async {
						isLoading(false)

						switch result {
						case .success(let validationConditions):
							self?.showCertificateSelectionScreen(validationConditions: validationConditions)
						case .failure(let error):
							self?.showErrorAlert(error: error)
						}
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

	private func showCertificateSelectionScreen(validationConditions: ValidationConditions) {
		let certificateSelectionViewController = TicketValidationCertificateSelectionViewController(
			viewModel: TicketValidationCertificateSelectionViewModel(
				validationConditions: validationConditions,
				healthCertificateService: healthCertificateService,
				onHealthCertificateCellTap: { [weak self] healthCertificate, healthCertifiedPerson in
					self?.showSecondConsentScreen(selectedCertificate: healthCertificate, selectedCertifiedPerson: healthCertifiedPerson)
				}
			),
			onDismiss: {
				self.showDismissAlert()
			}
		)
		
		DispatchQueue.main.async { [self] in
			if #available(iOS 13.0, *) {
				certificateSelectionViewController.isModalInPresentation = true
			}
			
			self.navigationController.pushViewController(certificateSelectionViewController, animated: true)
		}
	}
	
	private func showSecondConsentScreen(
		selectedCertificate: HealthCertificate,
		selectedCertifiedPerson: HealthCertifiedPerson
	) {
		
	}

	private func showSecondConsentScreen(selectedCertificate: HealthCertificate) {

	}

	private func showResultScreen(for result: TicketValidationResult) {

	}

	private func showErrorAlert(error: TicketValidationError) {
		let alert = UIAlertController(
			title: AppStrings.TicketValidation.Error.title,
			message: error.localizedDescription,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionOk,
				style: .default
			)
		)

		DispatchQueue.main.async {
			self.navigationController.present(alert, animated: true)
		}
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
					self?.ticketValidation.cancel()
					self?.navigationController.dismiss(animated: true)
				}
			)
		)
		navigationController.present(alert, animated: true)
	}

}
