////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class CheckinCoordinator {
	
	// MARK: - Init
	init(
		store: Store,
		eventStore: EventStoringProviding,
		appConfiguration: AppConfigurationProviding,
		eventCheckoutService: EventCheckoutService
	) {
		self.store = store
		self.eventStore = eventStore
		self.appConfiguration = appConfiguration
		self.eventCheckoutService = eventCheckoutService
		
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
			},
			onMissingPermissionsButtonTap: { [weak self] in
				self?.showSettings()
			}
		)
		
		let footerView = FooterView(
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
			bottomView: footerView
		)
		
		// show the info screen only once
		if !infoScreenShown {
			return UINavigationController(rootViewController: infoScreen(hidesCloseButton: true, dismissAction: { [weak self] in
				guard let self = self else { return }
				// Push Checkin Table View Controller
				self.viewController.pushViewController(topBottomContainerViewController, animated: true)
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
		// Info view MUST be shown
		guard self.infoScreenShown else {
			Log.debug("Checkin info screen not shown. Skipping further navigation", log: .ui)
			// set this to true to open qr code scanner screen after info screen has been dismissed
			self.showQRCodeScanningScreenAfterInfoScreen = true
			return
		}
		
		let qrCodeScanner = CheckinQRCodeScannerViewController(
			qrCodeVerificationHelper: verificationService,
			appConfiguration: appConfiguration,
			didScanCheckin: { [weak self] traceLocation in
				self?.viewController.dismiss(animated: true, completion: {
					self?.showTraceLocationDetails(traceLocation)
				})
			},
			dismiss: { [weak self] in
				self?.checkinsOverviewViewModel.updateForCameraPermission()
				self?.viewController.dismiss(animated: true)
			}
		)
		qrCodeScanner.definesPresentationContext = true
		DispatchQueue.main.async { [weak self] in
			let navigationController = UINavigationController(rootViewController: qrCodeScanner)
			navigationController.modalPresentationStyle = .fullScreen
			self?.viewController.present(navigationController, animated: true)
		}
	}
	
	func showTraceLocationDetailsFromExternalCamera(_ qrCodeString: String) {
		// Info view MUST be shown
		guard infoScreenShown else {
			Log.debug("Checkin info screen not shown. Skipping further navigation", log: .ui)
			// set this to true to open trace location details screen after info screen has been dismissed
			qrCodeAfterInfoScreen = qrCodeString
			return
		}
		verificationService.verifyQrCode(
			qrCodeString: qrCodeString,
			appConfigurationProvider: self.appConfiguration,
			onSuccess: { [weak self] traceLocation in
				self?.showTraceLocationDetails(traceLocation)
				self?.verificationService.subscriptions.removeAll()
			},
			onError: { [weak self] error in
				let alert = UIAlertController(
					title: AppStrings.Checkins.QRScanner.Error.title,
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
				self?.verificationService.subscriptions.removeAll()
			}
		)
	}
	
	// MARK: - Private

	private let store: Store
	private let eventStore: EventStoringProviding
	private let appConfiguration: AppConfigurationProviding
	private let eventCheckoutService: EventCheckoutService
	private var subscriptions: [AnyCancellable] = []
	private let verificationService = QRCodeVerificationHelper()

	private var infoScreenShown: Bool {
		get { store.checkinInfoScreenShown }
		set { store.checkinInfoScreenShown = newValue }
	}
	private var qrCodeAfterInfoScreen: String?
	private var showQRCodeScanningScreenAfterInfoScreen: Bool = false
	
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
		let footerView = FooterView(
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
			bottomView: footerView
		)
		viewController.present(topBottomContainerViewController, animated: true)
	}
	
	private func showTraceLocationDetails(_ traceLocation: TraceLocation) {
		let viewModel = TraceLocationCheckinViewModel(traceLocation, eventStore: self.eventStore, store: self.store)
		let traceLocationCheckinViewController = TraceLocationCheckinViewController(
			viewModel,
			dismiss: { [weak self] in
				self?.viewController.dismiss(animated: true)
			}
		)
		self.viewController.present(traceLocationCheckinViewController, animated: true)
	}

	
	private func showSettings() {
		LinkHelper.open(urlString: UIApplication.openSettingsURLString)
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
		
		let footerView = FooterView(
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
			bottomView: footerView
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
