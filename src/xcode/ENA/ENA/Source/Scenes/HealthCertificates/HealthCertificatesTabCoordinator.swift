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
		healthCertificateRequestService: HealthCertificateRequestService,
		healthCertificateValidationService: HealthCertificateValidationProviding,
		healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding,
		qrScannerCoordinator: QRScannerCoordinator,
		appConfigProvider: AppConfigurationProviding,
		restServiceProvider: RestServiceProviding
	) {
		self.store = store
		self.cclService = cclService
		self.healthCertificateService = healthCertificateService
		self.healthCertificateRequestService = healthCertificateRequestService
		self.healthCertificateValidationService = healthCertificateValidationService
		self.healthCertificateValidationOnboardedCountriesProvider = healthCertificateValidationOnboardedCountriesProvider
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
		self.qrScannerCoordinator = qrScannerCoordinator
		self.appConfigProvider = appConfigProvider
		self.restServiceProvider = restServiceProvider
		self.cclScenariosHelper = CCLScenariosHelper(cclService: cclService, store: store)
		
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
						
						self.viewController.pushViewController(self.overviewScreen, animated: animated)

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
	private let healthCertificateRequestService: HealthCertificateRequestService
	private let healthCertificateValidationService: HealthCertificateValidationProviding
	private let healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding
	private let qrScannerCoordinator: QRScannerCoordinator
	private let activityIndicatorView = QRScannerActivityIndicatorView(title: AppStrings.HealthCertificate.Overview.loadingIndicatorLabel)
	private let appConfigProvider: AppConfigurationProviding
	private let restServiceProvider: RestServiceProviding
	private let cclScenariosHelper: CCLScenariosHelper
	private var certificateCoordinator: HealthCertificateCoordinator?
	private var healthCertifiedPersonCoordinator: HealthCertifiedPersonCoordinator?

	private var subscriptions = Set<AnyCancellable>()
	private var printNavigationController: UINavigationController!
	
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
				healthCertificateRequestService: healthCertificateRequestService,
				cclService: cclService
			),
			cclService: cclService,
			onInfoBarButtonItemTap: { [weak self] in
				self?.presentInfoScreen()
			},
			onExportBarButtonItemTap: { [weak self] in
				self?.presentExportCertificatesInfoScreen()
			},
			onChangeAdmissionScenarioTap: { [weak self] in
				self?.showAdmissionScenarios()
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
			},
			showAlertAfterRegroup: { [weak self] in
				self?.showAlertAfterRegrouping()
				self?.store.shouldShowRegroupingAlert = false
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
	
	private func exportCertificatesInfoScreen(
		dismissAction: @escaping CompletionBool
	) -> TopBottomContainerViewController<HealthCertificateExportCertificatesInfoViewController, FooterViewController> {
		let healthCertificateExportCertificatesInfoViewController = HealthCertificateExportCertificatesInfoViewController(
			viewModel: .init(
				healthCertifiedPersons: healthCertificateService.healthCertifiedPersons,
				vaccinationValueSetsProvider: vaccinationValueSetsProvider
			),
			onDismiss: dismissAction,
			onTapContinue: { [weak self] pdfDocument in
				self?.showPdfGenerationResult(pdfDocument: pdfDocument)
			},
			showErrorAlert: { [weak self] error in
				guard let self = self else { return }
				
				switch error {
				case .fetchValueSets, .createStrongPointer:
					self.showPDFErrorAlert(
						title: AppStrings.HealthCertificate.PrintPDF.ErrorAlert.fetchValueSets.title,
						error: error)
				case .pdfGenerationFailed, .batchPDFGenerationFailed:
					self.showPDFErrorAlert(
						title: AppStrings.HealthCertificate.PrintPDF.ErrorAlert.pdfGeneration.title,
						error: error)
				case .noExportabeCertificate:
					self.showPDFErrorAlert(
						title: AppStrings.HealthCertificate.PrintPDF.ErrorAlert.noExportableCertificate.title,
						error: error)
				}
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.HealthCertificate.ExportCertificatesInfo.primaryButton,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true,
				backgroundColor: .enaColor(for: .background)
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: healthCertificateExportCertificatesInfoViewController,
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
	
	private func presentExportCertificatesInfoScreen() {
		let exportCertificatesInfoScreen = exportCertificatesInfoScreen(
			dismissAction: { [weak self] animated in
				self?.viewController.dismiss(animated: animated)
			}
		)
		
		printNavigationController = DismissHandlingNavigationController(
			rootViewController: exportCertificatesInfoScreen,
			transparent: true
		)
		
		viewController.present(printNavigationController, animated: true)
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
			},
			presentCovPassInfoScreen: { [weak self] viewController in
				self?.presentCovPassInfoScreen(rootViewController: viewController)
			},
			appConfigProvider: appConfigProvider,
			restServiceProvider: restServiceProvider
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

	private func showErrorAlert(
		title: String,
		error: Error
	) {
		DispatchQueue.main.async { [weak self] in

			guard let self = self else {
				fatalError("Could not create strong self")
			}
			
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
			
			self.viewController.present(alert, animated: true, completion: nil)
		}
	}

	private func showAlertAfterRegrouping() {
		let alert = UIAlertController(
			title: AppStrings.HealthCertificate.FaultTolerantNaming.title,
			message: AppStrings.HealthCertificate.FaultTolerantNaming.message,
			preferredStyle: .alert
		)

		let okAction = UIAlertAction(
			title: AppStrings.HealthCertificate.FaultTolerantNaming.okayButton,
			style: .cancel,
			handler: { _ in
				alert.dismiss(animated: true)
			}
		)

		alert.addAction(okAction)

		self.viewController.present(alert, animated: true, completion: nil)
	}
	
	private func showAdmissionScenarios() {
		let result = self.cclScenariosHelper.viewModelForAdmissionScenarios()
		switch result {
		case .success(let selectValueViewModel):
			let selectValueViewController = SelectValueTableViewController(
				selectValueViewModel,
				closeOnSelection: false,
				dismiss: { [weak self] in
					self?.viewController.presentedViewController?.dismiss(animated: true, completion: nil)
				}
			)
			
			let navigationController = UINavigationController(rootViewController: selectValueViewController)
			self.viewController.present(navigationController, animated: true)
			selectValueViewModel.$selectedValue.sink { [weak self] federalState in
				guard let state = federalState else { return }
				self?.healthCertificateService.lastSelectedScenarioIdentifier = state.identifier
				DispatchQueue.main.async { [weak self] in
					self?.showActivityIndicator(from: navigationController.view)
				}
				self?.healthCertificateService.updateDCCWalletInfosIfNeeded(
					isForced: true
				) { [weak self] in
					DispatchQueue.main.async {
						self?.hideActivityIndicator()
						self?.viewController.presentedViewController?.dismiss(animated: true, completion: nil)
					}
				}
			}.store(in: &self.subscriptions)
			
		case .failure(let error):
			self.showErrorAlert(title: AppStrings.HealthCertificate.Error.title, error: error)
		}
	}
	
	private func showPdfGenerationResult(pdfDocument: PDFDocument) {
		let healthCertificatePDFVersionViewModel = HealthCertificatePDFVersionViewModel(
			healthCertificate: nil, pdfDocument: pdfDocument
		)
		
		let healthCertificatePDFVersionViewController = HealthCertificatePDFVersionViewController(
			viewModel: healthCertificatePDFVersionViewModel,
			onTapPrintPdf: { [weak self] data in
				self?.showPrintPdf(pdfData: data)
			},
			onTapExportPdf: { [weak self] pdfItem in
				self?.exportPdf(exportItem: pdfItem)
			}
		)
		// The call of showPdfGenerationResult is made possibly in the background while generating the pdfDocument
		DispatchQueue.main.async { [weak self] in
			self?.printNavigationController.pushViewController(healthCertificatePDFVersionViewController, animated: true)
		}
	}
	
	private func showPrintPdf(
		pdfData: Data
	) {
		// swiftlint:disable:next no_plain_print
		guard UIPrintInteractionController.canPrint(pdfData) else {
			Log.error("UIPrintInteractionController can't print given pdf data")
			return
		}

		DispatchQueue.main.async {
			let printController = UIPrintInteractionController.shared
			printController.printingItem = pdfData
			printController.present(animated: true) { _, success, error in
				if let error = error {
					Log.error("Error printing pdf:", error: error)
				}
				if !success {
					Log.info("Failed to print pdf file")
				} else {
					Log.info("Did print pdf file successfully")
				}
			}
		}
	}
	
	private func exportPdf(
		exportItem: PDFExportItem
	) {
		let activityViewController = UIActivityViewController(activityItems: [exportItem], applicationActivities: nil)
		
		self.printNavigationController.present(activityViewController, animated: true, completion: nil)
	}
	
	private func showPDFErrorAlert(
		title: String,
		error: HealthCertificatePDFGenerationError
	) {
		let alert = UIAlertController(
			title: title,
			message: error.localizedDescription,
			preferredStyle: .alert
		)
		
		if error == .batchPDFGenerationFailed {
			let faqAction = UIAlertAction(
				title: AppStrings.HealthCertificate.PrintPDF.ErrorAlert.pdfGeneration.faq,
				style: .default,
				handler: { _ in
					LinkHelper.open(urlString: AppStrings.Links.healthCertificatePrintAllFAQ)
				}
			)
			faqAction.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.PrintPdf.faqAction
			alert.addAction(faqAction)
		}
		
		let okayAction = UIAlertAction(
			title: AppStrings.Common.alertActionOk,
			style: .cancel,
			handler: { [weak self] _ in
				self?.printNavigationController.dismiss(animated: true)
			}
		)
		okayAction.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.PrintPdf.okAction
		alert.addAction(okayAction)

		self.printNavigationController.present(alert, animated: true, completion: nil)
	}
}
