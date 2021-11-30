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

		navigationController = DismissHandlingNavigationController(rootViewController: firstConsentScreen)
		navigationController.navigationBar.prefersLargeTitles = true

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
			onDismiss: { [weak self] in
				self?.showDismissAlert()
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.TicketValidation.FirstConsent.primaryButtonTitle,
				secondaryButtonName: AppStrings.TicketValidation.FirstConsent.secondaryButtonTitle,
				primaryIdentifier: AccessibilityIdentifiers.TicketValidation.FirstConsent.primaryButton,
				secondaryIdentifier: AccessibilityIdentifiers.TicketValidation.FirstConsent.secondaryButton,
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

	private func showCertificateSelectionScreen(
        validationConditions: TicketValidationConditions
    ) {
		let certificateSelectionViewController = TicketValidationCertificateSelectionViewController(
			viewModel: TicketValidationCertificateSelectionViewModel(
				validationConditions: validationConditions,
				healthCertifiedPersons: healthCertificateService.healthCertifiedPersons,
				onHealthCertificateCellTap: { [weak self] healthCertificate, healthCertifiedPerson in
					self?.ticketValidation.selectCertificate(healthCertificate)
					self?.showSecondConsentScreen(selectedCertificate: healthCertificate, selectedCertifiedPerson: healthCertifiedPerson)
				}
			),
			onDismiss: { [weak self] isSupportedCertificatesEmpty in
				if isSupportedCertificatesEmpty {
					self?.ticketValidation.cancel()
					self?.navigationController.dismiss(animated: true)
				} else {
					self?.showDismissAlert()
				}
			}
		)
		
		if #available(iOS 13.0, *) {
			certificateSelectionViewController.isModalInPresentation = true
		}
		
		navigationController.pushViewController(certificateSelectionViewController, animated: true)
	}

	private func showSecondConsentScreen(
		selectedCertificate: HealthCertificate,
		selectedCertifiedPerson: HealthCertifiedPerson
	) {
		let secondConsentViewController = SecondTicketValidationConsentViewController(
			viewModel: SecondTicketValidationConsentViewModel(
				serviceIdentity: ticketValidation.initializationData.serviceIdentity,
				serviceProvider: ticketValidation.initializationData.serviceProvider,
				healthCertificate: selectedCertificate,
				healthCertifiedPerson: selectedCertifiedPerson,
				onDataPrivacyTap: {
					self.showDataPrivacy()
				}
			),
			onPrimaryButtonTap: { [weak self] isLoading in
				isLoading(true)
				
				self?.ticketValidation.validate { result in
					DispatchQueue.main.async {
						isLoading(false)

						switch result {
						case .success(let ticketValidationResult):
							self?.showResultScreen(for: ticketValidationResult)
						case .failure(let error):
							self?.showErrorAlert(error: error)
						}
					}
				}
			},
			onDismiss: { [weak self] in
				self?.showDismissAlert()
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.TicketValidation.SecondConsent.primaryButtonTitle,
				secondaryButtonName: AppStrings.TicketValidation.SecondConsent.secondaryButtonTitle,
				primaryIdentifier: AccessibilityIdentifiers.TicketValidation.SecondConsent.primaryButton,
				secondaryIdentifier: AccessibilityIdentifiers.TicketValidation.SecondConsent.secondaryButton,
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

	private func showResultScreen(for result: TicketValidationResultToken) {
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
			message: error.errorDescription(serviceProvider: ticketValidation.initializationData.serviceProvider),
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
