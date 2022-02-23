//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import PDFKit

// swiftlint:disable type_body_length
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
		showHealthCertifiedPerson(healthCertifiedPerson)
	}

	// MARK: - Private
	
	private let store: HealthCertificateStoring
	private let cclService: CCLServable
	private let healthCertificateService: HealthCertificateService
	private let healthCertificateValidationService: HealthCertificateValidationProviding
	private let healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding
	private let qrScannerCoordinator: QRScannerCoordinator
	private let activityIndicatorView = QRScannerActivityIndicatorView(title: AppStrings.HealthCertificate.Overview.loadingIndicatorLabel)

	private var modalNavigationController: DismissHandlingNavigationController!
	private var validationCoordinator: HealthCertificateValidationCoordinator?
	private var certificateCoordinator: HealthCertificateCoordinator?
	private var subscriptions = Set<AnyCancellable>()

	private var infoScreenShown: Bool {
		get { store.healthCertificateInfoScreenShown }
		set { store.healthCertificateInfoScreenShown = newValue }
	}

	// MARK: Show Screens

	private lazy var overviewScreen: HealthCertificateOverviewViewController = {
		return HealthCertificateOverviewViewController(
			viewModel: HealthCertificateOverviewViewModel(
				store: store,
				healthCertificateService: healthCertificateService,
				cclService: cclService
			),
			cclService: cclService,
			onInfoBarButtonItemTap: { [weak self] in
				self?.presentInfoScreen()
			},
			onChangeAdmissionScenarioTap: { [weak self] in
				guard let self = self else { return }

				self.showAdmissionScenarios()
			},
			onCertifiedPersonTap: { [weak self] healthCertifiedPerson in
				self?.showHealthCertifiedPerson(healthCertifiedPerson)
			},
			onCovPassCheckInfoButtonTap: { [weak self] in
				self?.presentCovPassInfoScreen()
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
	
	
	private func showAdmissionScenarios() {
		let result = self.cclService.dccAdmissionCheckScenarios()
		switch result {
		case .success(let scenarios):
			self.store.dccAdmissionCheckScenarios = scenarios
			let listItems = scenarios.scenarioSelection.items.map({
				SelectableValue(
					title: $0.titleText.localized(cclService: cclService),
					subtitle: $0.subtitleText?.localized(cclService: cclService),
					identifier: $0.identifier,
					isEnabled: $0.enabled
				)
			})
			let selectValueViewModel = SelectValueViewModel(
				listItems,
				presorted: true,
				title: scenarios.scenarioSelection.titleText.localized(cclService: cclService),
				preselected: nil,
				isInitialCellWithValue: true,
				initialValue: nil,
				accessibilityIdentifier: AccessibilityIdentifiers.LocalStatistics.selectState,
				selectionCellIconType: .none
			)
			let selectValueViewController = SelectValueTableViewController(
				selectValueViewModel,
				closeOnSelection: false,
				dismiss: { [weak self] in
					self?.viewController.presentedViewController?.dismiss(animated: true, completion: nil)
				}
			)
			let navigationController = UINavigationController(rootViewController: selectValueViewController)
			self.viewController.present(
				navigationController,
				animated: true
			)
			selectValueViewModel.$selectedValue.sink { [weak self] federalState in
				guard let self = self, let state = federalState else {
					return
				}
				self.healthCertificateService.lastSelectedScenarioIdentifier = state.identifier
				DispatchQueue.main.async { [weak self] in
					self?.showActivityIndicator(from: navigationController.view)
				}
				self.healthCertificateService.updateDCCWalletInfosIfNeeded(
					isForced: true
				) { [weak self] in
					DispatchQueue.main.async {
						self?.hideActivityIndicator()
						self?.viewController.presentedViewController?.dismiss(animated: true, completion: nil)
					}
				}
			}.store(in: &subscriptions)
		case .failure(let error):
			showErrorAlert(title: AppStrings.HealthCertificate.Error.title, error: error)
			Log.error(error.localizedDescription)
		}
	}

	private func showActivityIndicator(from view: UIView) {
		activityIndicatorView.alpha = 0.0
		activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(activityIndicatorView)
		NSLayoutConstraint.activate(
			[
				activityIndicatorView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
				activityIndicatorView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
				activityIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				activityIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
			]
		)

		let animator = UIViewPropertyAnimator(duration: 0.45, curve: .easeIn) { [weak self] in
			self?.activityIndicatorView.alpha = 1.0
		}
		animator.startAnimation()
	}

	private func hideActivityIndicator() {
		let animator = UIViewPropertyAnimator(duration: 0.45, curve: .easeIn) { [weak self] in
			self?.activityIndicatorView.alpha = 0.0
		}
		animator.addCompletion { [weak self] _ in
			self?.activityIndicatorView.removeFromSuperview()
		}
		animator.startAnimation()
	}
	
	private func showHealthCertifiedPerson(
		_ healthCertifiedPerson: HealthCertifiedPerson
	) {
		let healthCertificatePersonViewController = HealthCertifiedPersonViewController(
			cclService: cclService,
			healthCertificateService: healthCertificateService,
			healthCertifiedPerson: healthCertifiedPerson,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			dismiss: { [weak self] in
				self?.viewController.dismiss(animated: true)
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
						self?.viewController.dismiss(animated: true)
					}
				)
				self?.modalNavigationController.pushViewController(boosterDetailsViewController, animated: true)
			},
			didTapHealthCertificate: { [weak self] healthCertificate in
				self?.showHealthCertificateFlow(
					healthCertifiedPerson: healthCertifiedPerson,
					healthCertificate: healthCertificate,
					isPushed: true
				)
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
								self.viewController.dismiss(animated: true)
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
				self.presentCovPassInfoScreen(rootViewController: self.modalNavigationController)
			}
		)
		modalNavigationController = DismissHandlingNavigationController(rootViewController: healthCertificatePersonViewController)
		viewController.present(modalNavigationController, animated: true)
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
			
			self.modalNavigationController.present(alert, animated: true, completion: nil)
		}
	}
	
	private func setupCertificateBadgeCount() {
		healthCertificateService.unseenNewsCount
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.viewController.tabBarItem.badgeValue = $0 > 0 ? String($0) : nil
			}
			.store(in: &subscriptions)
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
		modalNavigationController.present(alert, animated: true)
	}
	
	private func showHealthCertificateFlow(
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificate: HealthCertificate,
		isPushed: Bool = false
	) {
		let parentingViewController = isPushed ? ParentingViewController.push(modalNavigationController) : ParentingViewController.present(viewController)
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
	
	private func showValidationFlow(
		healthCertificate: HealthCertificate,
		countries: [Country]
	) {
		validationCoordinator = HealthCertificateValidationCoordinator(
			parentViewController: modalNavigationController,
			healthCertificate: healthCertificate,
			countries: countries,
			store: store,
			healthCertificateValidationService: healthCertificateValidationService,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
		)

		validationCoordinator?.start()
	}
}
