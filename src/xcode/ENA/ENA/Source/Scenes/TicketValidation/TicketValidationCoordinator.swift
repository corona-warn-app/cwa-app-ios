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

	private func showCertificateSelectionScreen(validationConditions: TicketValidationConditions) {

	}

	private func showSecondConsentScreen(selectedCertificate: HealthCertificate) {

	}

	private func showResultScreen(for result: TicketValidationResult) {
		let viewModel: TicketValidationResultViewModel

		switch result.result {
		case .passed:
			viewModel = TicketValidationPassedViewModel(
				serviceProvider: ticketValidation.initializationData.serviceProvider
			)
		case .open:
			viewModel = TicketValidationOpenViewModel(
				serviceProvider: ticketValidation.initializationData.serviceProvider,
				validationResultItems: result.results
			)
		case .failed:
			viewModel = TicketValidationFailedViewModel(
				serviceProvider: ticketValidation.initializationData.serviceProvider,
				validationResultItems: result.results
			)
		}

		let resultViewController = TicketValidationResultViewController(
			viewModel: viewModel,
			onDismiss: { [weak self] in
				self?.navigationController.dismiss(animated: true)
			}
		)

		navigationController.pushViewController(resultViewController, animated: true)
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
