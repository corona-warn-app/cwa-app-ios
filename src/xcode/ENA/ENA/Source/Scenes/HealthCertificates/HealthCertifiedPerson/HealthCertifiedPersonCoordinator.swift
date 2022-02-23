//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class HealthCertifiedPersonCoordinator {

	// MARK: - Init

	init(
		store: HealthCertificateStoring,
		parentViewController: UIViewController,
		cclService: CCLServable,
		healthCertificateService: HealthCertificateService,
		healthCertificateValidationService: HealthCertificateValidationProviding,
		healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding,
		showHealthCertificateFlow: @escaping (HealthCertifiedPerson, HealthCertificate, Bool) -> Void,
		presentCovPassInfoScreen: @escaping (UIViewController) -> Void
	) {
		self.store = store
		self.parentViewController = parentViewController
		self.cclService = cclService
		self.healthCertificateService = healthCertificateService
		self.healthCertificateValidationService = healthCertificateValidationService
		self.healthCertificateValidationOnboardedCountriesProvider = healthCertificateValidationOnboardedCountriesProvider
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
		self.showHealthCertificateFlow = showHealthCertificateFlow
		self.presentCovPassInfoScreen = presentCovPassInfoScreen
		// set an empty starting viewController
		self.navigationController = DismissHandlingNavigationController(rootViewController: UIViewController())
	}

	// MARK: - Internal

	let navigationController: DismissHandlingNavigationController

	func showHealthCertifiedPerson(_ healthCertifiedPerson: HealthCertifiedPerson) {
		let healthCertifiedPersonViewController = healthCertifiedPersonViewController(healthCertifiedPerson)
		navigationController.viewControllers = [healthCertifiedPersonViewController]
		parentViewController?.present(navigationController, animated: true)
	}

	// MARK: - Private

	private let store: HealthCertificateStoring
	private let cclService: CCLServable
	private let healthCertificateService: HealthCertificateService
	private let healthCertificateValidationService: HealthCertificateValidationProviding
	private let healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding
	private let showHealthCertificateFlow: (HealthCertifiedPerson, HealthCertificate, Bool) -> Void
	private let presentCovPassInfoScreen: (UIViewController) -> Void

	private weak var parentViewController: UIViewController?

	private var validationCoordinator: HealthCertificateValidationCoordinator?

	private func healthCertifiedPersonViewController(
		_ healthCertifiedPerson: HealthCertifiedPerson
	) -> HealthCertifiedPersonViewController {
		HealthCertifiedPersonViewController(
			cclService: cclService,
			healthCertificateService: healthCertificateService,
			healthCertifiedPerson: healthCertifiedPerson,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			dismiss: { [weak self] in
				self?.navigationController.dismiss(animated: true)
			},
			didTapValidationButton: { [weak self] healthCertificate, setLoadingState in
				setLoadingState(true)

				self?.healthCertificateValidationOnboardedCountriesProvider.onboardedCountries { result in
					DispatchQueue.main.async {
						setLoadingState(false)
						switch result {
						case .success(let countries):
							self?.showValidationFlow(
								healthCertificate: healthCertificate,
								countries: countries
							)
						case .failure(let error):
							self?.showErrorAlert(
								title: AppStrings.HealthCertificate.Validation.Error.title,
								error: error
							)
						}
					}
				}
			},
			didTapBoosterNotification: { [weak self] healthCertifiedPerson in
				guard let boosterNotification = healthCertifiedPerson.dccWalletInfo?.boosterNotification, let cclService = self?.cclService else {
					return
				}
				let boosterDetailsViewController = BoosterDetailsViewController(
					viewModel: BoosterDetailsViewModel(cclService: cclService, healthCertifiedPerson: healthCertifiedPerson, boosterNotification: boosterNotification),
					dismiss: { [weak self] in
						self?.navigationController.dismiss(animated: true)
					}
				)
				self?.navigationController.pushViewController(boosterDetailsViewController, animated: true)
			},
			didTapHealthCertificate: { [weak self] healthCertificate in
				self?.showHealthCertificateFlow(healthCertifiedPerson, healthCertificate, true)
			},
			didSwipeToDelete: { [weak self] healthCertificate, confirmDeletion in
				self?.showDeleteAlert(
					certificateType: healthCertificate.type,
					submitAction: UIAlertAction(
						title: AppStrings.HealthCertificate.Alert.deleteButton,
						style: .destructive,
						handler: { _ in
							guard let self = self else {
								Log.error("Could not create strong self")
								return
							}
							self.healthCertificateService.moveHealthCertificateToBin(healthCertificate)
							// Do not confirm deletion if we removed the last certificate of the person (this removes the person, too) because it would trigger a new reload of the table where no person can be shown. Instead, we dismiss the view controller.
							if self.healthCertificateService.healthCertifiedPersons.contains(where: { $0 === healthCertifiedPerson }) {
								confirmDeletion()
							} else {
								self.navigationController.dismiss(animated: true)
							}
						}
					)
				)
			},
			showInfoHit: { [weak self] in
				guard let self = self else {
					Log.error("Failed to stronger self")
					return
				}
				self.presentCovPassInfoScreen(self.navigationController)
			},
			didTapUpdateNotification: { [weak self] in
				// add code to find healthCertificate for update here
				guard let healthCertificate = healthCertifiedPerson.mostRelevantHealthCertificate else {
					Log.error("missing health certificate to update")
					return
				}
				self?.showUpdateConsent(healthCertificate, healthCertifiedPerson)
			}
		)
	}

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

	private func showUpdateConsent(_ healthCertificate: HealthCertificate, _ healthCertifiedPerson: HealthCertifiedPerson) {
		let updateConsentViewController = HealthCertifiedPersonReissuanceConsentViewController(
			healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			didTapDataPrivacy: { [weak self] in
				self?.showDataPrivacy()
			},
			presentAlert: { [weak self] okAction, retryAction in
				let alert = UIAlertController(
					title: AppStrings.HealthCertificate.Person.UpdateConsent.defaultAlertTitle,
					message: AppStrings.HealthCertificate.Person.UpdateConsent.defaultAlertMessage,
					preferredStyle: .alert
				)
				alert.addAction(okAction)
				alert.addAction(retryAction)
				self?.navigationController.present(alert, animated: true)
			},
			presentUpdateSuccess: { [weak self] in
				self?.presentUpdateSucceeded()
			},
			didCancel: { [weak self] in
				self?.navigationController.popToRootViewController(animated: true)
			},
			dismiss: { [weak self] in
				self?.navigationController.dismiss(animated: true)
			}
		)

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.HealthCertificate.Person.UpdateConsent.primaryButtonTitle,
			secondaryButtonName: AppStrings.HealthCertificate.Person.UpdateConsent.secondaryButtonTitle,
			isPrimaryButtonEnabled: false,
			isSecondaryButtonEnabled: true,
			primaryCustomDisableBackgroundColor: .enaColor(for: .backgroundLightGray),
			secondaryCustomDisableBackgroundColor: .enaColor(for: .backgroundLightGray)
		)
		let footerViewController = FooterViewController(footerViewModel)

		let containerViewController = TopBottomContainerViewController(
			topController: updateConsentViewController,
			bottomController: footerViewController
		)
		navigationController.restoreOriginalNavigationBar()
		navigationController.pushViewController(containerViewController, animated: true)
	}

	private func presentUpdateSucceeded() {
		let updateSucceededViewController = HealthCertifiedPersonReissuanceSucceededViewController(
			didTapEnd: { [weak self] in
				self?.navigationController.popToRootViewController(animated: true)
			}
		)
		navigationController.pushViewController(updateSucceededViewController, animated: true)
	}

	private func showDeleteAlert(
		certificateType: HealthCertificate.CertificateType,
		submitAction: UIAlertAction
	) {
		let title: String
		let message: String

		switch certificateType {
		case .vaccination:
			title = AppStrings.HealthCertificate.Alert.VaccinationCertificate.title
			message = AppStrings.HealthCertificate.Alert.VaccinationCertificate.message
		case .test:
			title = AppStrings.HealthCertificate.Alert.TestCertificate.title
			message = AppStrings.HealthCertificate.Alert.TestCertificate.message
		case .recovery:
			title = AppStrings.HealthCertificate.Alert.RecoveryCertificate.title
			message = AppStrings.HealthCertificate.Alert.RecoveryCertificate.message
		}

		let alert = UIAlertController(
			title: title,
			message: message,
			preferredStyle: .alert
		)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.HealthCertificate.Alert.cancelButton,
				style: .cancel,
				handler: nil
			)
		)
		alert.addAction(submitAction)
		navigationController.present(alert, animated: true)
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
			guard let self = self else {
				fatalError("Could not create strong self")
			}

			self.navigationController.present(alert, animated: true, completion: nil)
		}
	}

	private func showValidationFlow(
		healthCertificate: HealthCertificate,
		countries: [Country]
	) {
		validationCoordinator = HealthCertificateValidationCoordinator(
			parentViewController: navigationController,
			healthCertificate: healthCertificate,
			countries: countries,
			store: store,
			healthCertificateValidationService: healthCertificateValidationService,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
		)

		validationCoordinator?.start()
	}

}
