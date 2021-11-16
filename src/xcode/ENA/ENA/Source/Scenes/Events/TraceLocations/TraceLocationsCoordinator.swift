//
// 🦠 Corona-Warn-App
//

import UIKit
import PDFKit

class TraceLocationsCoordinator {
	
	// MARK: - Init
	
	init(
		store: Store,
		appConfig: AppConfigurationProviding,
		qrCodePosterTemplateProvider: QRCodePosterTemplateProviding,
		eventStore: EventStoringProviding,
		client: Client,
		parentNavigationController: UINavigationController,
		qrScannerCoordinator: QRScannerCoordinator
	) {
		self.store = store
		self.appConfig = appConfig
		self.qrCodePosterTemplateProvider = qrCodePosterTemplateProvider
		self.eventStore = eventStore
		self.client = client
		self.parentNavigationController = parentNavigationController
		self.qrScannerCoordinator = qrScannerCoordinator
	}
	
	// MARK: - Internal
	
	func start() {
		parentNavigationController.pushViewController(overviewScreen, animated: true)
		
		#if DEBUG
		if isUITesting {
			store.traceLocationsInfoScreenShown = LaunchArguments.infoScreen.traceLocationsInfoScreenShown.boolValue
		}
		#endif
		
		if !infoScreenShown {
			showInfoScreen()
		}
	}
	
	// MARK: - Private
	
	private let store: Store
	private let appConfig: AppConfigurationProviding
	private let qrCodePosterTemplateProvider: QRCodePosterTemplateProviding
	private let eventStore: EventStoringProviding
	private let client: Client
	private let qrScannerCoordinator: QRScannerCoordinator

	private weak var parentNavigationController: UINavigationController!
	
	private var traceLocationDetailsNavigationController: UINavigationController!
	private var traceLocationAddingNavigationController: UINavigationController!

	private var onBehalfCheckinSubmissionCoordinator: OnBehalfCheckinSubmissionCoordinator?
	
	private var infoScreenShown: Bool {
		get { store.traceLocationsInfoScreenShown }
		set { store.traceLocationsInfoScreenShown = newValue }
	}

	// MARK: Show Screens
	
	private lazy var overviewScreen: UIViewController = {
		let traceLocationsOverviewViewController = TraceLocationsOverviewViewController(
			viewModel: TraceLocationsOverviewViewModel(
				store: eventStore,
				onEntryCellTap: { [weak self] traceLocation in
					self?.showTraceLocationDetailsScreen(traceLocation: traceLocation)
				},
				onEntryCellButtonTap: { [weak self] traceLocation in
					self?.showCheckInScreen(traceLocation: traceLocation)
				}
			),
			onInfoButtonTap: { [weak self] in
				self?.showInfoScreen()
			},
			onOnBehalfCheckinSubmissionTap: { [weak self] in
				self?.showOnBehalfCheckinSubmissionFlow()
			},
			onAddEntryCellTap: { [weak self] in
				self?.showTraceLocationTypeSelectionScreen()
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.TraceLocations.Overview.deleteAllButtonTitle,
				isSecondaryButtonEnabled: false,
				isPrimaryButtonHidden: true,
				isSecondaryButtonHidden: true,
				primaryButtonColor: .systemRed
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: traceLocationsOverviewViewController,
			bottomController: footerViewController
		)
		
		return topBottomContainerViewController
	}()
	
	private func showInfoScreen() {
		let alreadyDidConsentOnce = infoScreenShown
		// Promise the navigation view controller will be available,
		// this is needed to resolve an inset issue with large titles
		var navigationController: UINavigationController!
		let traceLocationsInfoViewController = TraceLocationsInfoViewController(
			viewModel: TraceLocationsInfoViewModel(
				presentDisclaimer: {
					let detailViewController = HTMLViewController(model: AppInformationModel.privacyModel)
					detailViewController.title = AppStrings.AppInformation.privacyTitle
					detailViewController.isDismissable = false
					if #available(iOS 13.0, *) {
						detailViewController.isModalInPresentation = true
					}
					// hides the footer view as well
					detailViewController.hidesBottomBarWhenPushed = true
					navigationController.pushViewController(detailViewController, animated: true)
				}
			),
			onDismiss: { [weak self] didConsent in
				if !alreadyDidConsentOnce {
					self?.infoScreenShown = didConsent
				}

				if !(alreadyDidConsentOnce || didConsent) {
					self?.parentNavigationController?.popViewController(animated: false)
				}
				navigationController.dismiss(animated: true, completion: nil)
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.TraceLocations.Information.primaryButtonTitle,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true
			),
			didTapPrimaryButton: {
				navigationController.dismiss(animated: true)
				
				// set to true only if user gives the consent
				self.infoScreenShown = true
			}
		)
		
		let topBottomLayoutViewController = TopBottomContainerViewController(
			topController: traceLocationsInfoViewController,
			bottomController: footerViewController
		)
		navigationController = UINavigationController(rootViewController: topBottomLayoutViewController)
		
		parentNavigationController?.present(navigationController, animated: true)
	}

	private func showTraceLocationDetailsScreen(traceLocation: TraceLocation) {
		let qrCodeErrorCorrectionLevel = appConfig.currentAppConfig.value.presenceTracingParameters.qrCodeErrorCorrectionLevel
		let mappedErrorCorrectionLevel = MappedErrorCorrectionType(qrCodeErrorCorrectionLevel: qrCodeErrorCorrectionLevel)

		let traceLocationDetailsViewController = TraceLocationDetailsViewController(
			viewModel: TraceLocationDetailsViewModel(
				traceLocation: traceLocation,
				store: store,
				qrCodePosterTemplateProvider: qrCodePosterTemplateProvider,
				qrCodeErrorCorrectionLevel: mappedErrorCorrectionLevel
			),
			onPrintVersionButtonTap: { [weak self] pdfView in
				DispatchQueue.main.async {
					self?.showPrintVersionScreen(pdfView: pdfView, traceLocation: traceLocation)
				}
			},
			onDuplicateButtonTap: { [weak self] traceLocation in
				guard let self = self else { return }

				self.showTraceLocationConfigurationScreen(
					on: self.traceLocationDetailsNavigationController,
					mode: .duplicate(traceLocation)
				)
			},
			onDismiss: { [weak self] in
				self?.parentNavigationController?.dismiss(animated: true)
			}
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.TraceLocations.Details.printVersionButtonTitle,
				secondaryButtonName: AppStrings.TraceLocations.Details.duplicateButtonTitle,
				isPrimaryButtonHidden: false,
				isSecondaryButtonHidden: false,
				secondaryButtonInverted: true,
				backgroundColor: .enaColor(for: .cellBackground)
			)
		)

		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: traceLocationDetailsViewController,
			bottomController: footerViewController
		)

		traceLocationDetailsNavigationController = UINavigationController(rootViewController: topBottomContainerViewController)
		parentNavigationController?.present(traceLocationDetailsNavigationController, animated: true)
	}

	private func showPrintVersionScreen(pdfView: PDFView, traceLocation: TraceLocation) {
		let viewController = TraceLocationPrintVersionViewController(
			viewModel: TraceLocationPrintVersionViewModel(pdfView: pdfView, traceLocation: traceLocation)
		)

		traceLocationDetailsNavigationController?.pushViewController(viewController, animated: true)
	}
	
	private func showTraceLocationTypeSelectionScreen() {
		let traceLocationTypeSelectionViewController = TraceLocationTypeSelectionViewController(
			viewModel: TraceLocationTypeSelectionViewModel([
				.location: TraceLocationType.permanentTypes,
				.event: TraceLocationType.temporaryTypes
			],
			onTraceLocationTypeSelection: { [weak self] traceLocationType in
				guard let self = self else { return }
				
				self.showTraceLocationConfigurationScreen(
					on: self.traceLocationAddingNavigationController,
					mode: .new(traceLocationType)
				)
			}
			),
			onDismiss: { [weak self] in
				self?.traceLocationAddingNavigationController.dismiss(animated: true)
			}
		)
		
		traceLocationAddingNavigationController = UINavigationController(rootViewController: traceLocationTypeSelectionViewController)
		traceLocationAddingNavigationController.navigationBar.prefersLargeTitles = true
		parentNavigationController?.present(traceLocationAddingNavigationController, animated: true)
	}
	
	private func showTraceLocationConfigurationScreen(on navigationController: UINavigationController, mode: TraceLocationConfigurationViewModel.Mode) {
		let traceLocationConfigurationViewController = TraceLocationConfigurationViewController(
			viewModel: TraceLocationConfigurationViewModel(
				mode: mode,
				eventStore: eventStore
			),
			onDismiss: {
				navigationController.dismiss(animated: true)
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.TraceLocations.Configuration.primaryButtonTitle,
				primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.primaryButton,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true,
				primaryCustomDisableBackgroundColor: .enaColor(for: .cellBackground)
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: traceLocationConfigurationViewController,
			bottomController: footerViewController
		)
		
		navigationController.pushViewController(topBottomContainerViewController, animated: true)
	}
	
	private func showCheckInScreen(traceLocation: TraceLocation) {
		let viewModel = TraceLocationCheckinViewModel(traceLocation, eventStore: eventStore, store: store)
		let traceLocationCheckinViewController = TraceLocationCheckinViewController(
			viewModel,
			dismiss: { [weak self] in
				self?.parentNavigationController?.dismiss(animated: true)
			}
		)
		let navigationController = DismissHandlingNavigationController(rootViewController: traceLocationCheckinViewController, transparent: true)
		parentNavigationController?.present(navigationController, animated: true)
	}

	private func showOnBehalfCheckinSubmissionFlow() {
		onBehalfCheckinSubmissionCoordinator = OnBehalfCheckinSubmissionCoordinator(
			parentViewController: parentNavigationController,
			appConfiguration: appConfig,
			eventStore: eventStore,
			client: client,
			qrScannerCoordinator: qrScannerCoordinator
		)

		onBehalfCheckinSubmissionCoordinator?.start()
	}
	
}
