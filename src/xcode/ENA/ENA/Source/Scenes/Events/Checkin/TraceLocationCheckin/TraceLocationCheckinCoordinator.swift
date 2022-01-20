//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class TraceLocationCheckinCoordinator {
	
	// MARK: - Init
	
	init(
		parentViewController: UIViewController,
		traceLocation: TraceLocation,
		store: Store,
		eventStore: EventStoringProviding,
		appConfiguration: AppConfigurationProviding,
		eventCheckoutService: EventCheckoutService
	) {
		self.parentViewController = parentViewController
		self.traceLocation = traceLocation
		self.store = store
		self.eventStore = eventStore
		self.appConfiguration = appConfiguration
		self.eventCheckoutService = eventCheckoutService
		
		#if DEBUG
		if isUITesting {
			store.checkinInfoScreenShown = LaunchArguments.infoScreen.checkinInfoScreenShown.boolValue
		}
		#endif
	}
	
	// MARK: - Internal

	func start() {
		navigationController = rootNavigationController
		parentViewController.present(navigationController, animated: true)
	}
	
	// MARK: - Private
	
	private let traceLocation: TraceLocation
	private let store: Store
	private let eventStore: EventStoringProviding
	private let appConfiguration: AppConfigurationProviding
	private let eventCheckoutService: EventCheckoutService
	
	private weak var parentViewController: UIViewController!
	private var navigationController: UINavigationController!
	
	private var infoScreenShown: Bool {
		get { store.checkinInfoScreenShown }
		set { store.checkinInfoScreenShown = newValue }
	}
	
	private lazy var rootNavigationController: UINavigationController = {
		if !infoScreenShown {
			return DismissHandlingNavigationController(
				rootViewController: infoScreen(
					hidesCloseButton: true,
					dismissAction: { [weak self] animated in
						guard let self = self else {
							Log.error("Could not create self reference")
							return
						}
						
						if animated {
							self.navigationController.pushViewController(self.traceLocationCheckin, animated: true)
						}

						// Set CertificateViewController as the only controller on the navigation stack to avoid back gesture etc.
						self.navigationController.setViewControllers([self.traceLocationCheckin], animated: false)
						
						self.infoScreenShown = true
					},
					
					showDetail: { detailViewController in
						self.navigationController.pushViewController(detailViewController, animated: true)
					}
				),
				transparent: true
			)
		} else {
			return DismissHandlingNavigationController(rootViewController: traceLocationCheckin, transparent: true)
		}
	}()
	
	private lazy var traceLocationCheckin: UIViewController = {
		let viewModel = TraceLocationCheckinViewModel(
			traceLocation,
			eventStore: eventStore,
			store: store
		)
		return TraceLocationCheckinViewController(
			viewModel,
			dismiss: { [weak self] in
				self?.navigationController.dismiss(animated: true)
			}
		)
	}()
	
	private func infoScreen(
		hidesCloseButton: Bool = false,
		dismissAction: @escaping (_ animated: Bool) -> Void,
		onDemand: Bool = false,
		showDetail: @escaping ((UIViewController) -> Void)
	) -> UIViewController {
		
		let checkinsInfoScreenViewController = CheckinsInfoScreenViewController(
			viewModel: CheckInsInfoScreenViewModel(
				presentDisclaimer: {
					let detailViewController = HTMLViewController(model: AppInformationModel.privacyModel)
					detailViewController.title = AppStrings.AppInformation.privacyTitle
					detailViewController.isDismissable = false
					if #available(iOS 13.0, *) {
						detailViewController.isModalInPresentation = true
					}
					showDetail(detailViewController)
				},
				hidesCloseButton: hidesCloseButton
			),
			store: store,
			onDemand: onDemand,
			onDismiss: { animated in
				dismissAction(animated)
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.Checkins.Information.primaryButtonTitle,
				primaryIdentifier: AccessibilityIdentifiers.Checkin.Information.primaryButton,
				isSecondaryButtonEnabled: false,
				isPrimaryButtonHidden: false,
				isSecondaryButtonHidden: true
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: checkinsInfoScreenViewController,
			bottomController: footerViewController
		)
		
		return topBottomContainerViewController
	}
}
