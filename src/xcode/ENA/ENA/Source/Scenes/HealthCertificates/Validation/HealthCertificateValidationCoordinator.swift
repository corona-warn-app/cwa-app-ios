//
// 🦠 Corona-Warn-App
//

import UIKit

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
		navigationController = UINavigationController(rootViewController: validationScreen)
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

	lazy var validationScreen: UIViewController = {
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
					case .success(let countries):
//						self.showValidationFlow(
//							healthCertificate: healthCertificate,
//							countries: countries
//						)
					break
					case .failure(let error):
//						self.showErrorAlert(
//							title: AppStrings.HealthCertificate.ValidationError.title,
//							error: error
//						)
					break
					}
				}
			},
			onDisclaimerButtonTap: {
				
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

	}
	
}
