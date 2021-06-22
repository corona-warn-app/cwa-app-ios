////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class HealthCertificatesCoordinator {
	
	// MARK: - Init
	
	init(
		store: HealthCertificateStoring,
		healthCertificateService: HealthCertificateService,
		vaccinationValueSetsProvider: VaccinationValueSetsProvider
	) {
		self.store = store
		self.healthCertificateService = healthCertificateService
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider

		#if DEBUG
		if isUITesting {
			store.healthCertificateInfoScreenShown = LaunchArguments.infoScreen.healthCertificateInfoScreenShown.boolValue
		}
		#endif

		setupCertificateBadgeCount()
	}
	
	// MARK: - Internal
	
	lazy var viewController: UINavigationController = {
		if !infoScreenShown {
			return UINavigationController(
				rootViewController: infoScreen(
					hidesCloseButton: true,
					dismissAction: { [weak self] in
						guard let self = self else { return }

						self.viewController.pushViewController(self.overviewScreen, animated: true)
						// Set Overview as the only Controller on the navigation stack to avoid back gesture etc.
						self.viewController.setViewControllers([self.overviewScreen], animated: false)

						self.infoScreenShown = true
					},
					showDetail: { detailViewController in
						self.viewController.pushViewController(detailViewController, animated: true)
					}
				)
			)
		} else {
			return UINavigationController(rootViewController: overviewScreen)
		}
	}()
	
	// MARK: - Private
	
	private let store: HealthCertificateStoring
	private let healthCertificateService: HealthCertificateService
	private let vaccinationValueSetsProvider: VaccinationValueSetsProvider

	private var modalNavigationController: UINavigationController!

	private var subscriptions = Set<AnyCancellable>()

	private var infoScreenShown: Bool {
		get { store.healthCertificateInfoScreenShown }
		set { store.healthCertificateInfoScreenShown = newValue }
	}

	// MARK: Show Screens

	private lazy var overviewScreen: HealthCertificateOverviewViewController = {
		return HealthCertificateOverviewViewController(
			viewModel: HealthCertificateOverviewViewModel(
				healthCertificateService: healthCertificateService
			),
			onInfoBarButtonItemTap: { [weak self] in
				self?.presentInfoScreen()
			},
			onCreateHealthCertificateTap: { [weak self] in
				guard let self = self else { return }

				self.showQRCodeScanner(from: self.viewController)
			},
			onCertifiedPersonTap: { [weak self] healthCertifiedPerson in
				self?.showHealthCertifiedPerson(healthCertifiedPerson)
			},
			onMissingPermissionsButtonTap: { [weak self] in
				self?.showSettings()
			}
		)
	}()

	private func infoScreen(
		hidesCloseButton: Bool = false,
		dismissAction: @escaping (() -> Void),
		showDetail: @escaping ((UIViewController) -> Void)
	) -> TopBottomContainerViewController<HealthCertificateInfoViewController, FooterViewController> {
		let consentScreen = HealthCertificateInfoViewController(
			viewModel: HealthCertificateInfoViewModel(
				hidesCloseButton: hidesCloseButton,
				didTapDataPrivacy: {
					let detailViewController = HTMLViewController(model: AppInformationModel.privacyModel)
					detailViewController.title = AppStrings.AppInformation.privacyTitle
					detailViewController.isDismissable = false

					if #available(iOS 13.0, *) {
						detailViewController.isModalInPresentation = true
					}

					showDetail(detailViewController)
				}
			),
			dismiss: dismissAction
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.HealthCertificate.Info.primaryButton,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true,
				backgroundColor: .enaColor(for: .background)
			)
		)

		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: consentScreen,
			bottomController: footerViewController
		)

		return topBottomContainerViewController
	}

	private func presentInfoScreen() {
		// Promise the navigation view controller will be available,
		// this is needed to resolve an inset issue with large titles
		var navigationController: UINavigationController!
		let infoVC = infoScreen(
			dismissAction: {
				navigationController.dismiss(animated: true)
			},
			showDetail: { detailViewController in
				navigationController.pushViewController(detailViewController, animated: true)
			}
		)

		// We need to use UINavigationController(rootViewController: UIViewController) here,
		// otherwise the inset of the navigation title is wrong
		navigationController = UINavigationController(rootViewController: infoVC)
		viewController.present(navigationController, animated: true)
	}
	
	private func showQRCodeScanner(from presentingViewController: UIViewController) {
		let qrCodeScannerViewController = HealthCertificateQRCodeScannerViewController(
			healthCertificateService: healthCertificateService,
			didScanCertificate: { [weak self] healthCertifiedPerson, healthCertificate in
				presentingViewController.dismiss(animated: true) {
					if presentingViewController == self?.viewController {
						self?.showHealthCertificate(
							healthCertifiedPerson: healthCertifiedPerson,
							healthCertificate: healthCertificate,
							shouldPushOnModalNavigationController: false
						)
					}
				}
			},
			dismiss: {
				presentingViewController.dismiss(animated: true)
			}
		)

		qrCodeScannerViewController.definesPresentationContext = true

		let qrCodeNavigationController = UINavigationController(rootViewController: qrCodeScannerViewController)
		qrCodeNavigationController.modalPresentationStyle = .fullScreen

		presentingViewController.present(qrCodeNavigationController, animated: true)
	}
	
	private func showHealthCertifiedPerson(
		_ healthCertifiedPerson: HealthCertifiedPerson
	) {
		let healthCertificatePersonViewController = HealthCertifiedPersonViewController(
			healthCertificateService: healthCertificateService,
			healthCertifiedPerson: healthCertifiedPerson,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			dismiss: { [weak self] in
				self?.viewController.dismiss(animated: true)
			},
			didTapHealthCertificate: { [weak self] healthCertificate in
				self?.showHealthCertificate(
					healthCertifiedPerson: healthCertifiedPerson,
					healthCertificate: healthCertificate,
					shouldPushOnModalNavigationController: true
				)
			},
			didSwipeToDelete: { [weak self] healthCertificate, confirmDeletion in
				self?.showDeleteAlert(
					certificateType: healthCertificate.type,
					submitAction: UIAlertAction(
						title: AppStrings.HealthCertificate.Alert.deleteButton,
						style: .default,
						handler: { _ in
							self?.healthCertificateService.removeHealthCertificate(healthCertificate)
							confirmDeletion()
						}
					)
				)
			}
		)

		modalNavigationController = UINavigationController(rootViewController: healthCertificatePersonViewController)
		viewController.present(modalNavigationController, animated: true)
	}
	
	private func showHealthCertificate(
		healthCertifiedPerson: HealthCertifiedPerson?,
		healthCertificate: HealthCertificate,
		shouldPushOnModalNavigationController: Bool
	) {
		let healthCertificateViewController = HealthCertificateViewController(
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			dismiss: { [weak self] in
				self?.viewController.dismiss(animated: true)
			},
			didTapDelete: { [weak self] in
				let deleteButtonTitle: String

				switch healthCertificate.type {
				case .vaccination:
					deleteButtonTitle = AppStrings.HealthCertificate.Alert.deleteButton
				case .test:
					deleteButtonTitle = AppStrings.HealthCertificate.Alert.TestCertificate.deleteButton
				case .recovery:
					deleteButtonTitle = AppStrings.HealthCertificate.Alert.RecoveryCertificate.deleteButton
				}

				self?.showDeleteAlert(
					certificateType: healthCertificate.type,
					submitAction: UIAlertAction(
						title: deleteButtonTitle,
						style: .default,
						handler: { _ in
							self?.healthCertificateService.removeHealthCertificate(healthCertificate)

							if shouldPushOnModalNavigationController {
								self?.modalNavigationController.popToRootViewController(animated: true)
							} else {
								self?.modalNavigationController.dismiss(animated: true)
							}
						}
					)
				)
			}
		)

		let primaryButtonTitle: String
		switch healthCertificate.type {
		case .vaccination:
			primaryButtonTitle = AppStrings.HealthCertificate.Details.primaryButton
		case .test:
			primaryButtonTitle = AppStrings.HealthCertificate.Details.TestCertificate.primaryButton
		case .recovery:
			primaryButtonTitle = AppStrings.HealthCertificate.Details.RecoveryCertificate.primaryButton
		}
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: primaryButtonTitle,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true,
				primaryButtonInverted: true,
				backgroundColor: .enaColor(for: .cellBackground),
				primaryTextColor: .systemRed
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: healthCertificateViewController,
			bottomController: footerViewController
		)

		if shouldPushOnModalNavigationController {
			modalNavigationController.pushViewController(topBottomContainerViewController, animated: true)
		} else {
			modalNavigationController = UINavigationController(rootViewController: topBottomContainerViewController)
			viewController.present(self.modalNavigationController, animated: true)
		}
	}
	
	private func showDeleteAlert(
		certificateType: HealthCertificate.CertificateType,
		submitAction: UIAlertAction
	) {
		let title: String
		let message: String
		let cancelButtonTitle: String

		switch certificateType {
		case .vaccination:
			title = AppStrings.HealthCertificate.Alert.title
			message = AppStrings.HealthCertificate.Alert.message
			cancelButtonTitle = AppStrings.HealthCertificate.Alert.cancelButton
		case .test:
			title = AppStrings.HealthCertificate.Alert.TestCertificate.title
			message = AppStrings.HealthCertificate.Alert.TestCertificate.message
			cancelButtonTitle = AppStrings.HealthCertificate.Alert.TestCertificate.cancelButton
		case .recovery:
			title = AppStrings.HealthCertificate.Alert.RecoveryCertificate.title
			message = AppStrings.HealthCertificate.Alert.RecoveryCertificate.message
			cancelButtonTitle = AppStrings.HealthCertificate.Alert.RecoveryCertificate.cancelButton
		}

		let alert = UIAlertController(
			title: title,
			message: message,
			preferredStyle: .alert
		)
		alert.addAction(
			UIAlertAction(
				title: cancelButtonTitle,
				style: .cancel,
				handler: nil
			)
		)
		alert.addAction(submitAction)
		modalNavigationController.present(alert, animated: true)
	}

	private func setupCertificateBadgeCount() {
		healthCertificateService.unseenTestCertificateCount
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.viewController.tabBarItem.badgeValue = $0 > 0 ? String($0) : nil
			}
			.store(in: &subscriptions)
	}
	
	private func showSettings() {
		LinkHelper.open(urlString: UIApplication.openSettingsURLString)
	}
	
}
