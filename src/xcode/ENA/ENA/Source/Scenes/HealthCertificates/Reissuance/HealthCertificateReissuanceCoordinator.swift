//
// 🦠 Corona-Warn-App
//

import UIKit

final class HealthCertificateReissuanceCoordinator {
	
	// MARK: - Init
	
	init(
		parentViewController: UIViewController,
		healthCertificateService: HealthCertificateService,
		restServiceProvider: RestServiceProviding,
		appConfigProvider: AppConfigurationProviding,
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificate: HealthCertificate,
		cclService: CCLServable
	) {
		self.parentViewController = parentViewController
		self.healthCertificateService = healthCertificateService
		self.restServiceProvider = restServiceProvider
		self.appConfigProvider = appConfigProvider
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

	private let healthCertificateService: HealthCertificateService
	private let restServiceProvider: RestServiceProviding
	private let appConfigProvider: AppConfigurationProviding
	private let healthCertifiedPerson: HealthCertifiedPerson
	private let healthCertificate: HealthCertificate
	private let cclService: CCLServable

	// MARK: Show Screens

	private lazy var reissuanceScreen: UIViewController = {
		let consentViewController = HealthCertificateReissuanceConsentViewController(
			healthCertificateService: healthCertificateService,
			restServiceProvider: restServiceProvider,
			appConfigProvider: appConfigProvider,
			cclService: cclService,
			certificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			didTapDataPrivacy: { [weak self] in
				self?.showDataPrivacy()
			},
			onError: { [weak self] error in
				self?.showReissuanceError(error)
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

	private func showReissuanceError(_ error: HealthCertificateReissuanceError) {
		let alert = UIAlertController(
			title: AppStrings.HealthCertificate.Reissuance.Consent.defaultAlertTitle,
			message: error.localizedDescription,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.HealthCertificate.Reissuance.Consent.defaultAlertOKButton,
				style: .default
			)
		)

		navigationController.present(alert, animated: true)
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
