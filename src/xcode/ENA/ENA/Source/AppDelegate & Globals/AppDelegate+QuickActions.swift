////
// 🦠 Corona-Warn-App
//

import UIKit
import AVFoundation

// MARK: - Quick Actions

enum QuickAction: String {
	
	/// General identifiers for quick actions
	case qrCodeScanner = "de.rki.coronawarnapp.shortcut.qrcodescanner"
	case showCertificates = "de.rki.coronawarnapp.shortcut.certificates"
	case eventCheckin = "de.rki.coronawarnapp.shortcut.eventcheckin"
	case diaryNewEntry = "de.rki.coronawarnapp.shortcut.diarynewentry"

	static var exposureSubmissionFlowTestResult: TestResult?
	
	private static var willResignActiveNotification: NSObjectProtocol?
	
	static func setup() {
		guard willResignActiveNotification == nil else {
			return
		}
		Log.info("[QuickAction] setup", log: .ui)
		willResignActiveNotification = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { _ in
			update()
		}
		// setup initial quick actions
		update()
	}
	
	/// Adds or removes quick actions according to the current application state
	private static func update() {
		
		Log.info(#function, log: .ui)
		
		let application = UIApplication.shared
				
		// No shortcuts if test result positiv
		if let testResult = exposureSubmissionFlowTestResult, testResult == .positive {
			Log.info("[QuickAction] Remove all shortcut items since exposure submission test result is positiv", log: .ui)
			application.shortcutItems = nil
			return
		}

		// No shortcuts if not onboarded
		guard let appDelegate = application.delegate as? AppDelegate, appDelegate.store.isOnboarded else {
			Log.info("[QuickAction] Remove all shortcut items since onboarding is not done yet", log: .ui)
			application.shortcutItems = nil
			return
		}

		var shortcutItems = [
			UIApplicationShortcutItem(type: QuickAction.diaryNewEntry.rawValue, localizedTitle: AppStrings.QuickActions.contactDiaryNewEntry, localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "book.closed")),
			UIApplicationShortcutItem(type: QuickAction.showCertificates.rawValue, localizedTitle: AppStrings.QuickActions.showCertificates, localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "Icons_Tabbar_Certificates"))
		]
		
		let status = AVCaptureDevice.authorizationStatus(for: .video)
		if status == .authorized || status == .notDetermined {
			// dont show camera related actions if no camera access is granted
			shortcutItems.append(
				contentsOf: [
					UIApplicationShortcutItem(type: QuickAction.qrCodeScanner.rawValue, localizedTitle: AppStrings.QuickActions.qrCodeScanner, localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "qrcode.viewfinder")),
					UIApplicationShortcutItem(type: QuickAction.eventCheckin.rawValue, localizedTitle: AppStrings.QuickActions.eventCheckin, localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "Icons_Tabbar_Checkin"))
				]
			)
		}
		
		application.shortcutItems = shortcutItems
	}
}

extension AppDelegate {

	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		handleShortcutItem(shortcutItem)
	}

	/// Checks whether the application is launched from a shortcut or not.
	///
	/// - Parameter launchOptions: the launch options passed in the app launch (will/did) functions
	/// - Returns: `false` if the application was launched(!) from a shortcut to prevent further calls to `application(_:performActionFor:completionHandler:)`
	func handleQuickActions(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {

			// We have to wait for the exposure manager to activate in `AppDelegate.showHome()`.
			// Instead of blocking the thread (or refactoring the whole app-bootstrapping) we'll delay the handling for the shortcut item.
			DispatchQueue.global().async {
				while self.coordinator.tabBarController == nil {
					usleep(100_000) // 0.1s
				}
				DispatchQueue.main.sync {
					self.handleShortcutItem(shortcutItem)
				}
			}

			// prevents triggering `application(_:performActionFor:completionHandler:)`
			// see: https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622935-application
			return false
		}
		return true
	}

	/// General handler for all shortcut items.
	///
	///  Currently implemented:
	///   - New Dictionary Entry
	///
	/// - Parameter shortcutItem: the item to launch
	func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
		Log.debug("Did open app via shortcut \(shortcutItem.type)", log: .ui)
		switch shortcutItem.type {
		case QuickAction.qrCodeScanner.rawValue:
			Log.info("Shortcut: QR code scanner", log: .ui)
			guard let tabBarController = coordinator.tabBarController else { return }
			tabBarController.selectedIndex = 0
			
			// dismiss an overlaying, modally presented view controller
			coordinator.checkinTabCoordinator?.viewController.presentedViewController?.dismiss(animated: false, completion: nil)
			
			// open qr code scanner for fast event checkin
			coordinator.checkinTabCoordinator?.showQRCodeScanner()
			
		case QuickAction.showCertificates.rawValue:
			Log.info("Shortcut: Certificates", log: .ui)
			guard let tabBarController = coordinator.tabBarController else { return }
			tabBarController.selectedIndex = 1
			
			// dismiss an overlaying, modally presented view controller
			coordinator.checkinTabCoordinator?.viewController.presentedViewController?.dismiss(animated: false, completion: nil)
			
		case QuickAction.eventCheckin.rawValue:
			Log.info("Shortcut: Event checkin 📷", log: .ui)
			guard let tabBarController = coordinator.tabBarController else { return }
			tabBarController.selectedIndex = 3
			
			// dismiss an overlaying, modally presented view controller
			coordinator.checkinTabCoordinator?.viewController.presentedViewController?.dismiss(animated: false, completion: nil)

		case QuickAction.diaryNewEntry.rawValue:
			Log.info("Shortcut: Open new diary entry", log: .ui)
			guard let tabBarController = coordinator.tabBarController else { return }
			tabBarController.selectedIndex = 4

			// dismiss an overlaying, modally presented view controller
			coordinator.diaryCoordinator?.viewController.presentedViewController?.dismiss(animated: false, completion: nil)

			// let diary coordinator handle pre-checks & navigation
			coordinator.diaryCoordinator?.showCurrentDayScreen()
			
		default:
			Log.warning("unhandled shortcut item type \(shortcutItem.type)", log: .ui)
			assertionFailure("Check this!")
		}
	}
}

extension RootCoordinator {

	/// Direct access to the tabbar controller
	fileprivate var tabBarController: UITabBarController? {
		viewController.children.compactMap({ $0 as? UITabBarController }).first
	}
}
