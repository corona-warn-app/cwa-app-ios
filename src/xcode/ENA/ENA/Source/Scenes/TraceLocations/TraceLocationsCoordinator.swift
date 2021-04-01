//
// 🦠 Corona-Warn-App
//

import UIKit
import PDFKit

class TraceLocationsCoordinator {
	
	// MARK: - Init
	
	init(
		store: Store,
		qrCodePosterTemplateProvider: QRCodePosterTemplateProviding,
		eventStore: EventStoringProviding,
		parentNavigationController: UINavigationController
	) {
		self.store = store
		self.qrCodePosterTemplateProvider = qrCodePosterTemplateProvider
		self.eventStore = eventStore
		self.parentNavigationController = parentNavigationController
	}
	
	// MARK: - Internal
	
	func start() {
		parentNavigationController?.pushViewController(overviewScreen, animated: true)
		
		#if DEBUG
		if isUITesting {
			if let TraceLocationsInfoScreenShown = UserDefaults.standard.string(forKey: "TraceLocationsInfoScreenShown") {
				store.traceLocationsInfoScreenShown = (TraceLocationsInfoScreenShown != "NO")
			}
		}
		#endif
		
		if !infoScreenShown {
			showInfoScreen()
		}
	}
	
	// MARK: - Private
	
	private let store: Store
	private let qrCodePosterTemplateProvider: QRCodePosterTemplateProviding
	private let eventStore: EventStoringProviding

	private weak var parentNavigationController: UINavigationController?
	
	private var traceLocationDetailsNavigationController: UINavigationController!
	private var traceLocationAddingNavigationController: UINavigationController!
	
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
		// Promise the navigation view controller will be available,
		// this is needed to resolve an inset issue with large titles
		var navigationController: UINavigationController!
		let traceLocationsInfoViewController = TraceLocationsInfoViewController(
			viewModel: TraceLocationsInfoViewModel(
				presentDisclaimer: {
					let detailViewController = HTMLViewController(model: AppInformationModel.privacyModel)
					detailViewController.title = AppStrings.AppInformation.privacyTitle
					// hides the footer view as well
					detailViewController.hidesBottomBarWhenPushed = true
					navigationController.pushViewController(detailViewController, animated: true)
				}
			),
			onDismiss: {
				navigationController.dismiss(animated: true)
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
			}
		)
		
		let topBottomLayoutViewController = TopBottomContainerViewController(
			topController: traceLocationsInfoViewController,
			bottomController: footerViewController
		)
		navigationController = UINavigationController(rootViewController: topBottomLayoutViewController)
		
		parentNavigationController?.present(navigationController, animated: true) {
			self.infoScreenShown = true
		}
	}
	
	private func showTraceLocationDetailsScreen(traceLocation: TraceLocation) {
		let traceLocationDetailsViewController = TraceLocationDetailsViewController(
			viewModel: TraceLocationDetailsViewModel(traceLocation: traceLocation, store: store, qrCodePosterTemplateProvider: qrCodePosterTemplateProvider),
			onPrintVersionButtonTap: { [weak self] pdfView in
				DispatchQueue.main.async {
					self?.showPrintVersionScreen(pdfView: pdfView)
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
				secondaryButtonInverted: true
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: traceLocationDetailsViewController,
			bottomController: footerViewController
		)
		
		traceLocationDetailsNavigationController = UINavigationController(rootViewController: topBottomContainerViewController)
		parentNavigationController?.present(traceLocationDetailsNavigationController, animated: true)
	}

	private func showPrintVersionScreen(pdfView: PDFView) {
		let viewController = TraceLocationPrintVersionViewController(
			viewModel: TraceLocationPrintVersionViewModel(pdfView: pdfView)
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
				isSecondaryButtonHidden: true
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: traceLocationConfigurationViewController,
			bottomController: footerViewController
		)
		
		navigationController.pushViewController(topBottomContainerViewController, animated: true)
	}
	
	private func showCheckInScreen(traceLocation: TraceLocation) {
		let viewModel = TraceLocationDetailViewModel(traceLocation, eventStore: eventStore, store: store)
		let checkinViewController = TraceLocationDetailViewController(
			viewModel,
			dismiss: { [weak self] in
				self?.parentNavigationController?.dismiss(animated: true)
			}
		)
		parentNavigationController?.present(checkinViewController, animated: true)
	}
	
}
