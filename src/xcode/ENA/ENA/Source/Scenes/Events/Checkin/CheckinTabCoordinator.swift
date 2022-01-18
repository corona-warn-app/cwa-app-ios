////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class CheckinTabCoordinator {
	
	// MARK: - Init
	init(
		store: Store,
		eventStore: EventStoringProviding,
		appConfiguration: AppConfigurationProviding,
		eventCheckoutService: EventCheckoutService,
		qrScannerCoordinator: QRScannerCoordinator
	) {
		self.store = store
		self.eventStore = eventStore
		self.appConfiguration = appConfiguration
		self.eventCheckoutService = eventCheckoutService
		self.qrScannerCoordinator = qrScannerCoordinator
		
		#if DEBUG
		if isUITesting {
			store.checkinInfoScreenShown = LaunchArguments.infoScreen.checkinInfoScreenShown.boolValue
		}
		#endif
		
		setupCheckinBadgeCount()
	}
	
	// MARK: - Internal
	lazy var viewController: UINavigationController = {
		let checkinsOverviewViewController = CheckinsOverviewViewController(
			viewModel: checkinsOverviewViewModel,
			onInfoButtonTap: { [weak self] in
				self?.presentInfoScreen()
			},
			onAddEntryCellTap: { [weak self] in
				self?.showQRCodeScanner()
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.Checkins.Overview.deleteAllButtonTitle,
				isSecondaryButtonEnabled: false,
				isPrimaryButtonHidden: true,
				isSecondaryButtonHidden: true,
				primaryButtonColor: .systemRed
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: checkinsOverviewViewController,
			bottomController: footerViewController
		)
		
		// show the info screen only once
		if !infoScreenShown {
			return UINavigationController(rootViewController: infoScreen(hidesCloseButton: true, dismissAction: { [weak self]  animated in
				guard let self = self else { return }
				
				if animated {
					// Push Checkin Table View Controller
					self.viewController.pushViewController(topBottomContainerViewController, animated: true)
				}
				
				// Set as the only controller on the navigation stack to avoid back gesture etc.
				self.viewController.setViewControllers([topBottomContainerViewController], animated: false)
				
				self.infoScreenShown = true // remember and don't show it again
				
				// open trace location details screen if necessary
				if let qrCode = self.qrCodeAfterInfoScreen {
					self.qrCodeAfterInfoScreen = nil
					self.showTraceLocationDetailsFromExternalCamera(qrCode)
				} else if self.showQRCodeScanningScreenAfterInfoScreen { // open qr code scanner screen if necessary
					self.showQRCodeScanner()
					self.showQRCodeScanningScreenAfterInfoScreen = false
				}
			},
			showDetail: { detailViewController in
				self.viewController.pushViewController(detailViewController, animated: true)
			}))
		} else {
			let navigationController = UINavigationController(rootViewController: topBottomContainerViewController)
			navigationController.navigationBar.prefersLargeTitles = true
			return navigationController
		}
	}()
		
	func showQRCodeScanner() {
		qrScannerCoordinator.start(
			parentViewController: viewController,
			presenter: .checkinTab
		)
	}
	
	func showTraceLocationDetailsFromExternalCamera(_ qrCodeString: String) {
		// Info view MUST be shown
		guard infoScreenShown else {
			Log.debug("Checkin info screen not shown. Skipping further navigation", log: .ui)
			// set this to true to open trace location details screen after info screen has been dismissed
			qrCodeAfterInfoScreen = qrCodeString
			return
		}

		let checkinQRCodeParser = CheckinQRCodeParser(
			appConfigurationProvider: appConfiguration
		)

		checkinQRCodeParser.verifyQrCode(
			qrCodeString: qrCodeString,
			onSuccess: { [weak self] traceLocation in
				self?.showTraceLocationDetails(traceLocation)
			},
			onError: { [weak self] error in
				let alert = UIAlertController(
					title: AppStrings.Checkins.QRScannerError.title,
					message: error.errorDescription,
					preferredStyle: .alert
				)
				alert.addAction(
					UIAlertAction(
						title: AppStrings.Common.alertActionOk,
						style: .default,
						handler: { _ in
							alert.dismiss(animated: true, completion: nil)
						}
					)
				)
				self?.viewController.present(alert, animated: true)
			}
		)
	}
	
	// MARK: - Private

	private let store: Store
	private let eventStore: EventStoringProviding
	private let appConfiguration: AppConfigurationProviding
	private let eventCheckoutService: EventCheckoutService
	private let qrScannerCoordinator: QRScannerCoordinator
	
	private var subscriptions: [AnyCancellable] = []
	private var qrCodeAfterInfoScreen: String?
	private var showQRCodeScanningScreenAfterInfoScreen: Bool = false
	private var traceLocationCheckinCoordinator: TraceLocationCheckinCoordinator?
	
	private var infoScreenShown: Bool {
		get { store.checkinInfoScreenShown }
		set { store.checkinInfoScreenShown = newValue }
	}
	private lazy var checkinsOverviewViewModel: CheckinsOverviewViewModel = {
		CheckinsOverviewViewModel(
			store: eventStore,
			eventCheckoutService: eventCheckoutService,
			onEntryCellTap: { [weak self] checkin in
				guard checkin.checkinCompleted else {
					Log.debug("Editing uncompleted checkin is not allowed", log: .default)
					return
				}
				self?.showEditCheckIn(checkin)
			}
		)
	}()

	private func showEditCheckIn(_ checkIn: Checkin) {
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.Checkins.Edit.primaryButtonTitle,
				secondaryButtonName: nil,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonEnabled: false,
				isPrimaryButtonHidden: false,
				isSecondaryButtonHidden: true,
				backgroundColor: .enaColor(for: .cellBackground)
			)
		)

		let editCheckInViewController = EditCheckinDetailViewController(
			eventStore: eventStore,
			checkIn: checkIn,
			dismiss: { [weak self] in
				self?.viewController.dismiss(animated: true)
			}
		)

		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: editCheckInViewController,
			bottomController: footerViewController
		)
		viewController.present(topBottomContainerViewController, animated: true)
	}
	
	private func showTraceLocationDetails(
		_ traceLocation: TraceLocation
	) {
		traceLocationCheckinCoordinator = TraceLocationCheckinCoordinator(
			parentViewController: viewController,
			traceLocation: traceLocation,
			store: store,
			eventStore: eventStore,
			appConfiguration: appConfiguration,
			eventCheckoutService: eventCheckoutService
		)
		
		traceLocationCheckinCoordinator?.start()
	}
	
	private func infoScreen(
		hidesCloseButton: Bool = false,
		dismissAction: @escaping (_ animated: Bool) -> Void,
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
	
	private func presentInfoScreen() {
		// Promise the navigation view controller will be available,
		// this is needed to resolve an inset issue with large titles
		var navigationController: UINavigationController!
		let infoVC = infoScreen(
			dismissAction: { animated in
				navigationController.dismiss(animated: animated)
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
	
	private func setupCheckinBadgeCount() {
		eventStore.checkinsPublisher
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] checkins in
				let activeCheckinCount = checkins.filter { !$0.checkinCompleted }.count
				self?.viewController.tabBarItem.badgeValue = activeCheckinCount > 0 ? String(activeCheckinCount) : nil
			}
			.store(in: &subscriptions)
	}

}
