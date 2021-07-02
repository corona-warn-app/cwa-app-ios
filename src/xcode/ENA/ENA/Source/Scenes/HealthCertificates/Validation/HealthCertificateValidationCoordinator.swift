////
// 🦠 Corona-Warn-App
//

import UIKit

final class HealthCertificateValidationCoordinator {
	
	// MARK: - Init
	
	init(
		parentViewController: UIViewController,
		store: HealthCertificateStoring,
		healthCertificateValidationService: HealthCertificateValidationProviding
	) {
		self.parentViewController = parentViewController
		self.store = store
		self.healthCertificateValidationService = healthCertificateValidationService
	}
	
	// MARK: - Internal

	func start() {
		parentViewController.present(validationScreen, animated: true)
	}
	
	// MARK: - Private

	private let parentViewController: UIViewController
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

		let healthCertificateViewController = UIViewController()

		return TopBottomContainerViewController(
			topController: healthCertificateViewController,
			bottomController: footerViewController
		)
	}()
	
}
