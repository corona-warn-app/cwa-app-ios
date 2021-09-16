//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class TraceLocationDetailsCoordinator {
	
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
		navigationController = DismissHandlingNavigationController(rootViewController: checkinDetailScreen)
		parentViewController.present(navigationController, animated: true)
	}
	
	// MARK: - Private
	
	private lazy var rootViewController: UINavigationController = {
		if !infoScreenShown {
			
		} else {
			
		}
	
		return let viewModel = TraceLocationCheckinViewModel(
			traceLocation,
			eventStore: eventStore,
			store: store
		)
		let traceLocationCheckinViewController = TraceLocationCheckinViewController(
			viewModel,
			dismiss: { [weak self] in
				self?.parentViewController.dismiss(animated: true)
			}
		)
		self.viewController.present(traceLocationCheckinViewController, animated: true)
	}()

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
	
	private func infoScreen(
		hidesCloseButton: Bool = false,
		dismissAction: @escaping (() -> Void),
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
			onDismiss: {
				dismissAction()
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
