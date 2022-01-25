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
		healthCertificateValidationService: HealthCertificateValidationProviding,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding
	) {
		self.parentViewController = parentViewController
		self.healthCertificate = healthCertificate
		self.countries = countries
		self.store = store
		self.healthCertificateValidationService = healthCertificateValidationService
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
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
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding

	// MARK: Show Screens

	private lazy var validationScreen: UIViewController = {
		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.HealthCertificate.Validation.buttonTitle,
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
					arrivalCountry: arrivalCountry,
					validationClock: arrivalDate
				) { result in
					DispatchQueue.main.async { [weak self] in
						guard let self = self else {
							Log.error("Could not create strong self.")
							return
						}
						footerViewModel.setLoadingIndicator(false, disable: false, button: .primary)

						switch result {
						case .success(let validationReport):
							switch validationReport {
							case .validationPassed(let validationResults):
								self.showValidationPassedScreen(
									arrivalCountry: arrivalCountry,
									arrivalDate: arrivalDate,
									validationResults: validationResults
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
							case let .TECHNICAL_VALIDATION_FAILED(expirationDate, signatureInvalid):
								self.showTechnicalValidationFailedScreen(
									arrivalCountry: arrivalCountry,
									arrivalDate: arrivalDate,
									expirationDate: expirationDate,
									signatureInvalid: signatureInvalid
								)
							default:
								self.showErrorAlert(
									title: AppStrings.HealthCertificate.Validation.Error.title,
									error: error
								)
							}
						}
					}
				}
			},
			onDisclaimerButtonTap: { [weak self] in
				let htmlViewController = HTMLViewController(model: AppInformationModel.privacyModel)
				htmlViewController.title = AppStrings.AppInformation.privacyTitle
				htmlViewController.isDismissable = false
				self?.navigationController.pushViewController(htmlViewController, animated: true)
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
		arrivalDate: Date,
		validationResults: [ValidationResult]
	) {
		let validationPassedViewController = HealthCertificateValidationResultViewController(
			viewModel: HealthCertificateValidationPassedViewModel(
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
				validationResults: validationResults,
				healthCertificate: healthCertificate,
				vaccinationValueSetsProvider: vaccinationValueSetsProvider
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
				validationResults: validationResults,
				healthCertificate: healthCertificate,
				vaccinationValueSetsProvider: vaccinationValueSetsProvider
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
		arrivalDate: Date,
		expirationDate: Date?,
		signatureInvalid: Bool
	) {
		let technicalValidationFailedViewController = HealthCertificateValidationResultViewController(
			viewModel: HealthCertificateTechnicalValidationFailedViewModel(
				arrivalCountry: arrivalCountry,
				arrivalDate: arrivalDate,
				expirationDate: expirationDate,
				signatureInvalid: signatureInvalid
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
		DispatchQueue.main.async { [weak self] in
			self?.navigationController.present(alert, animated: true, completion: nil)
		}
	}
	
}
