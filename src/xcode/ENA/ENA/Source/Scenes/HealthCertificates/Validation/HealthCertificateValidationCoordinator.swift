//
// 🦠 Corona-Warn-App
//

import UIKit
import class CertLogic.ValidationResult

final class HealthCertificateValidationCoordinator {
	
	// MARK: - Init
	
	init(
		parentViewController: UIViewController,
		healthCertificate: HealthCertificate,
		countries: [Country],
		store: HealthCertificateStoring,
		healthCertificateValidationService: HealthCertificateValidationProviding
	) {
		self.parentViewController = parentViewController
		self.healthCertificate = healthCertificate
		self.countries = countries
		self.store = store
		self.healthCertificateValidationService = healthCertificateValidationService
	}
	
	// MARK: - Internal

	func start() {
		navigationController = DismissHandlingNavigationController(rootViewController: validationScreen)
		parentViewController.present(navigationController, animated: true)
	}
	
	// MARK: - Private

	private weak var parentViewController: UIViewController!
	private var navigationController: UINavigationController!

	private let healthCertificate: HealthCertificate
	private let countries: [Country]
	private let store: HealthCertificateStoring
	private let healthCertificateValidationService: HealthCertificateValidationProviding

	// MARK: Show Screens

	private lazy var validationScreen: UIViewController = {
		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.HealthCertificate.Details.validationButtonTitle,
			isPrimaryButtonEnabled: true,
			isSecondaryButtonHidden: true,
			backgroundColor: .enaColor(for: .background)
		)

		let footerViewController = FooterViewController(footerViewModel)

		let healthCertificateViewController = HealthCertificateValidationViewController(
			healthCertificate: healthCertificate,
			countries: countries,
			store: store,
			onValidationButtonTap: { [weak self] arrivalCountry, arrivalDate in
				guard let self = self else { return }

				footerViewModel.setLoadingIndicator(true, disable: true, button: .primary)

				self.healthCertificateValidationService.validate(
					healthCertificate: self.healthCertificate,
					arrivalCountry: arrivalCountry.id,
					validationClock: arrivalDate
				) { result in
					footerViewModel.setLoadingIndicator(false, disable: false, button: .primary)

					switch result {
					case .success(let validationReport):
						switch validationReport {
						case .validationPassed:
							self.showValidationPassedScreen(
								arrivalCountry: arrivalCountry,
								arrivalDate: arrivalDate
							)
						case .validationOpen(let validationResults):
							self.showValidationOpenScreen(
								arrivalCountry: arrivalCountry,
								arrivalDate: arrivalDate,
								validationResults: validationResults
							)
						case .validationFailed(let validationResults):
							self.showValidationFailedScreen(
								arrivalCountry: arrivalCountry,
								arrivalDate: arrivalDate,
								validationResults: validationResults
							)
						}
					case .failure(let error):
						switch error {
						case .TECHNICAL_VALIDATION_FAILED:
							self.showTechnicalValidationFailedScreen(
								arrivalCountry: arrivalCountry,
								arrivalDate: arrivalDate
							)
						default:
							self.showErrorAlert(
								title: AppStrings.HealthCertificate.Validation.Error.title,
								error: error
							)
						}
					}
				}
			},
			onInfoButtonTap: { [weak self] in
				self?.showInfoScreen()
			},
			onDismiss: { [weak self] in
				self?.parentViewController.dismiss(animated: true)
			}
		)

		return TopBottomContainerViewController(
			topController: healthCertificateViewController,
			bottomController: footerViewController
		)
	}()

	private func showInfoScreen() {
		let validationInformationViewController = ValidationInformationViewController(
			dismiss: { [weak self] in
				self?.navigationController.dismiss(animated: true)
			}
		)
		let validationNavigationController = DismissHandlingNavigationController(rootViewController: validationInformationViewController, transparent: true)
		navigationController.present(validationNavigationController, animated: true)
	}

	private func showValidationPassedScreen(
		arrivalCountry: Country,
		arrivalDate: Date
	) {
		let validationPassedViewController = HealthCertificateValidationResultViewController(
			viewModel: HealthCertificateValidationPassedViewModel(
				arrivalCountry: arrivalCountry,
				arrivalDate: arrivalDate
			),
			onPrimaryButtonTap: { [weak self] in
				self?.navigationController.popToRootViewController(animated: true)
			},
			onDismiss: { [weak self] in
				self?.parentViewController.dismiss(animated: true)
			}
		)

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.HealthCertificate.Validation.Result.Passed.primaryButtonTitle,
			isPrimaryButtonEnabled: true,
			isSecondaryButtonHidden: true,
			backgroundColor: .enaColor(for: .background)
		)

		let footerViewController = FooterViewController(footerViewModel)

		let containerViewController = TopBottomContainerViewController(
			topController: validationPassedViewController,
			bottomController: footerViewController
		)

		navigationController.pushViewController(containerViewController, animated: true)
	}

	private func showValidationOpenScreen(
		arrivalCountry: Country,
		arrivalDate: Date,
		validationResults: [ValidationResult]
	) {
		let validationOpenViewController = HealthCertificateValidationResultViewController(
			viewModel: HealthCertificateValidationOpenViewModel(
				arrivalCountry: arrivalCountry,
				arrivalDate: arrivalDate,
				validationResults: validationResults
			),
			onPrimaryButtonTap: { [weak self] in
				self?.navigationController.popToRootViewController(animated: true)
			},
			onDismiss: { [weak self] in
				self?.parentViewController.dismiss(animated: true)
			}
		)

		navigationController.pushViewController(validationOpenViewController, animated: true)
	}

	private func showValidationFailedScreen(
		arrivalCountry: Country,
		arrivalDate: Date,
		validationResults: [ValidationResult]
	) {
		let validationFailedViewController = HealthCertificateValidationResultViewController(
			viewModel: HealthCertificateValidationFailedViewModel(
				arrivalCountry: arrivalCountry,
				arrivalDate: arrivalDate,
				validationResults: validationResults
			),
			onPrimaryButtonTap: { [weak self] in
				self?.navigationController.popToRootViewController(animated: true)
			},
			onDismiss: { [weak self] in
				self?.parentViewController.dismiss(animated: true)
			}
		)

		navigationController.pushViewController(validationFailedViewController, animated: true)
	}

	private func showTechnicalValidationFailedScreen(
		arrivalCountry: Country,
		arrivalDate: Date
	) {
		let technicalValidationFailedViewController = HealthCertificateValidationResultViewController(
			viewModel: HealthCertificateTechnicalValidationFailedViewModel(
				arrivalCountry: arrivalCountry,
				arrivalDate: arrivalDate
			),
			onPrimaryButtonTap: { [weak self] in
				self?.navigationController.popToRootViewController(animated: true)
			},
			onDismiss: { [weak self] in
				self?.parentViewController.dismiss(animated: true)
			}
		)

		navigationController.pushViewController(technicalValidationFailedViewController, animated: true)
	}

	private func showErrorAlert(
		title: String,
		error: Error
	) {
		let alert = UIAlertController(
			title: title,
			message: error.localizedDescription,
			preferredStyle: .alert
		)

		let okayAction = UIAlertAction(
			title: AppStrings.Common.alertActionOk,
			style: .cancel,
			handler: { _ in
				alert.dismiss(animated: true)
			}
		)
		alert.addAction(okayAction)

		navigationController.present(alert, animated: true, completion: nil)
	}
	
}
