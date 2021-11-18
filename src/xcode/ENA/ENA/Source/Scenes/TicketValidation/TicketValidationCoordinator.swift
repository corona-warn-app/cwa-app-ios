//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class TicketValidationCoordinator {
	
	// MARK: - Init
	
	init(
		parentViewController: UIViewController
	) {
		self.parentViewController = parentViewController
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

	}

	private func showSecondConsentScreen(
		selectedCertificate: HealthCertificate
	) {
		let secondConsentViewController = SecondTicketValidationConsentViewController(
			viewModel: SecondTicketValidationConsentViewModel(
				serviceIdentity: ticketValidation.initializationData.serviceIdentity,
				serviceProvider: ticketValidation.initializationData.serviceProvider,
				healthCertificate: selectedCertificate,
				onDataPrivacyTap: {
					self.showDataPrivacy()
				}
			),
			onPrimaryButtonTap: { [weak self] isLoading in
				isLoading(true)
				// call grantSecondConsent()
			},
			onDismiss: {
				self.showDismissAlert()
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.TicketValidation.SecondConsent.primaryButtonTitle,
				secondaryButtonName: AppStrings.TicketValidation.SecondConsent.secondaryButtonTitle,
				isSecondaryButtonEnabled: true,
				isPrimaryButtonHidden: false,
				isSecondaryButtonHidden: false
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: secondConsentViewController,
			bottomController: footerViewController
		)
		
		navigationController.pushViewController(topBottomContainerViewController, animated: true)
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
