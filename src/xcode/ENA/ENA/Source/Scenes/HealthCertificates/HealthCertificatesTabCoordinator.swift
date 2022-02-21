//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import PDFKit

final class HealthCertificatesTabCoordinator {
	
	// MARK: - Init
	
	init(
		store: HealthCertificateStoring,
		cclService: CCLServable,
		healthCertificateService: HealthCertificateService,
		healthCertificateValidationService: HealthCertificateValidationProviding,
		healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding,
		qrScannerCoordinator: QRScannerCoordinator
	) {
		self.store = store
		self.cclService = cclService
		self.healthCertificateService = healthCertificateService
		self.healthCertificateValidationService = healthCertificateValidationService
		self.healthCertificateValidationOnboardedCountriesProvider = healthCertificateValidationOnboardedCountriesProvider
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
		self.qrScannerCoordinator = qrScannerCoordinator

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
					dismissAction: { [weak self] animated in
						guard let self = self else { return }
						
						if animated {
							self.viewController.pushViewController(self.overviewScreen, animated: true)
						}

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

	func showCertifiedPersonWithCertificateFromNotification(
		for healthCertifiedPerson: HealthCertifiedPerson,
		with healthCertificate: HealthCertificate
	) {
		showHealthCertificateFlow(
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificate: healthCertificate
		)
	}
	
	func showCertifiedPersonFromNotification(for healthCertifiedPerson: HealthCertifiedPerson) {
		showHealthCertifiedPersonFlow(healthCertifiedPerson)
	}

	// MARK: - Private
	
	private let store: HealthCertificateStoring
	private let cclService: CCLServable
	private let healthCertificateService: HealthCertificateService
	private let healthCertificateValidationService: HealthCertificateValidationProviding
	private let healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding
	private let qrScannerCoordinator: QRScannerCoordinator

	private var certificateCoordinator: HealthCertificateCoordinator?
	private var healthCertifiedPersonCoordinator: HealthCertifiedPersonCoordinator?

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
			cclService: cclService,
			onInfoBarButtonItemTap: { [weak self] in
				self?.presentInfoScreen()
			},
			onCreateHealthCertificateTap: { [weak self] in
				guard let self = self else { return }

				self.showQRCodeScanner()
			},
			onCertifiedPersonTap: { [weak self] healthCertifiedPerson in
				self?.showHealthCertifiedPersonFlow(healthCertifiedPerson)
			},
			onCovPassCheckInfoButtonTap: { [weak self] in
				self?.presentCovPassInfoScreen()
			},
			onTapToDelete: { [weak self] decodingFailedHealthCertificate in
				self?.showDecodingFailedDeleteAlert(
					submitAction: UIAlertAction(
						title: AppStrings.HealthCertificate.Alert.DecodingFailedCertificate.deleteButton,
						style: .destructive,
						handler: { _ in
							self?.healthCertificateService.remove(decodingFailedHealthCertificate: decodingFailedHealthCertificate)
						}
					)
				)
			}
		)
	}()

	private func presentCovPassInfoScreen(rootViewController: UIViewController? = nil) {
		let presentViewController = rootViewController ?? viewController
		let covPassInformationViewController = CovPassCheckInformationViewController(
			onDismiss: {
				presentViewController.dismiss(animated: true)
			}
		)
		let navigationController = DismissHandlingNavigationController(rootViewController: covPassInformationViewController, transparent: true)
		presentViewController.present(navigationController, animated: true)
	}

	private func infoScreen(
		hidesCloseButton: Bool = false,
		dismissAction: @escaping (_ animated: Bool) -> Void,
		onDemand: Bool = false,
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
			store: store,
			onDemand: onDemand,
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
			dismissAction: { animated in
				navigationController.dismiss(animated: animated)
			},
			onDemand: true,
			showDetail: { detailViewController in
				navigationController.pushViewController(detailViewController, animated: true)
			}
		)
		// We need to use UINavigationController(rootViewController: UIViewController) here,
		// otherwise the inset of the navigation title is wrong
		navigationController = UINavigationController(rootViewController: infoVC)
		viewController.present(navigationController, animated: true)
	}
	
	private func showQRCodeScanner() {
		qrScannerCoordinator.start(
			parentViewController: viewController,
			presenter: .certificateTab
		)
	}

	private func setupCertificateBadgeCount() {
		healthCertificateService.unseenNewsCount
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.viewController.tabBarItem.badgeValue = $0 > 0 ? String($0) : nil
			}
			.store(in: &subscriptions)
	}

	private func showHealthCertifiedPersonFlow(_ healthCertifiedPerson: HealthCertifiedPerson) {
		healthCertifiedPersonCoordinator = HealthCertifiedPersonCoordinator(
			store: store,
			parentViewController: viewController,
			cclService: cclService,
			healthCertificateService: healthCertificateService,
			healthCertificateValidationService: healthCertificateValidationService,
			healthCertificateValidationOnboardedCountriesProvider: healthCertificateValidationOnboardedCountriesProvider,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			showHealthCertificateFlow: { [weak self] healthCertifiedPerson, healthCertificate, isPushed in
				self?.showHealthCertificateFlow(
					healthCertifiedPerson: healthCertifiedPerson,
					healthCertificate: healthCertificate,
					isPushed: isPushed
				)
			}, presentCovPassInfoScreen: { [weak self] viewController in
				self?.presentCovPassInfoScreen(rootViewController: viewController)
			}
		)
		healthCertifiedPersonCoordinator?.showHealthCertifiedPerson(healthCertifiedPerson)
	}

	private func showDecodingFailedDeleteAlert(
		submitAction: UIAlertAction
	) {
		let alert = UIAlertController(
			title: AppStrings.HealthCertificate.Alert.DecodingFailedCertificate.title,
			message: AppStrings.HealthCertificate.Alert.DecodingFailedCertificate.message,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.HealthCertificate.Alert.DecodingFailedCertificate.cancelButton,
				style: .cancel,
				handler: nil
			)
		)
		alert.addAction(submitAction)

		viewController.present(alert, animated: true)
	}
	
	private func showHealthCertificateFlow(
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificate: HealthCertificate,
		isPushed: Bool = false
	) {
		var parentingViewController: ParentingViewController
		if isPushed {
			guard let navigationController = healthCertifiedPersonCoordinator?.navigationController else {
				Log.error("Tried to push without a matching modal controller")
				return
			}
			parentingViewController = ParentingViewController.push(navigationController)
		} else {
			parentingViewController = ParentingViewController.present(viewController)
		}

		certificateCoordinator = HealthCertificateCoordinator(
			parentingViewController: parentingViewController,
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificate: healthCertificate,
			store: store,
			healthCertificateService: healthCertificateService,
			healthCertificateValidationService: healthCertificateValidationService,
			healthCertificateValidationOnboardedCountriesProvider: healthCertificateValidationOnboardedCountriesProvider,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			markAsSeenOnDisappearance: true
		)
		certificateCoordinator?.start()
	}

}
