//
// 🦠 Corona-Warn-App
//

import UIKit

final class HealthCertificateReissuanceCoordinator {
	
	// MARK: - Init
	
	init(
		parentViewController: UIViewController,
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificate: HealthCertificate,
		cclService: CCLServable
	) {
		self.parentViewController = parentViewController
		self.healthCertifiedPerson = healthCertifiedPerson
		self.healthCertificate = healthCertificate
		self.cclService = cclService
	}
	
	// MARK: - Internal

	func start() {
		navigationController = DismissHandlingNavigationController(rootViewController: reissuanceScreen)
		parentViewController.present(navigationController, animated: true)
	}
	
	// MARK: - Private

	private weak var parentViewController: UIViewController!
	private var navigationController: UINavigationController!

	private let healthCertifiedPerson: HealthCertifiedPerson
	private let healthCertificate: HealthCertificate
	private let cclService: CCLServable

	// MARK: Show Screens

	private lazy var reissuanceScreen: UIViewController = {
		let consentViewController = HealthCertificateReissuanceConsentViewController(
			cclService: cclService,
			certificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			didTapDataPrivacy: { [weak self] in
				self?.showDataPrivacy()
			},
			presentAlert: { [weak self] okAction, retryAction in
				let alert = UIAlertController(
					title: AppStrings.HealthCertificate.Reissuance.Consent.defaultAlertTitle,
					message: AppStrings.HealthCertificate.Reissuance.Consent.defaultAlertMessage,
					preferredStyle: .alert
				)
				alert.addAction(okAction)
				alert.addAction(retryAction)
				self?.navigationController.present(alert, animated: true)
			},
			onReissuanceSuccess: { [weak self] in
				self?.showReissuanceSucceeded()
			},
			dismiss: { [weak self] in
				self?.parentViewController.dismiss(animated: true)
			}
		)

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.HealthCertificate.Reissuance.Consent.primaryButtonTitle,
			secondaryButtonName: AppStrings.HealthCertificate.Reissuance.Consent.secondaryButtonTitle,
			isPrimaryButtonEnabled: true,
			isSecondaryButtonEnabled: true,
			primaryCustomDisableBackgroundColor: .enaColor(for: .backgroundLightGray),
			secondaryCustomDisableBackgroundColor: .enaColor(for: .backgroundLightGray)
		)
		let footerViewController = FooterViewController(footerViewModel)

		return TopBottomContainerViewController(
			topController: consentViewController,
			bottomController: footerViewController
		)
	}()

	private func showDataPrivacy() {
		let detailViewController = HTMLViewController(model: AppInformationModel.privacyModel)
		detailViewController.title = AppStrings.AppInformation.privacyTitle
		detailViewController.isDismissable = false
		if #available(iOS 13.0, *) {
			detailViewController.isModalInPresentation = true
		}
		detailViewController.navigationItem.largeTitleDisplayMode = .always
		detailViewController.navigationItem.hidesBackButton = false
		navigationController.pushViewController(detailViewController, animated: true)
	}

	private func showReissuanceSucceeded() {
		let reissuanceSucceededViewController = HealthCertificateReissuanceSucceededViewController(
			didTapEnd: { [weak self] in
				self?.parentViewController.dismiss(animated: true)
			}
		)
		navigationController.pushViewController(reissuanceSucceededViewController, animated: true)
	}
	
}
