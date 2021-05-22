////
// 🦠 Corona-Warn-App
//

import UIKit
import AVFoundation

// MARK: - Quick Actions

enum QuickAction: String {
	
	/// General identifier for the 'add diary entry' shortcut action
	case diaryNewEntry = "de.rki.coronawarnapp.shortcut.diarynewentry"
	case eventCheckin = "de.rki.coronawarnapp.shortcut.eventcheckin"
	
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
	
	/// Adds or removes quick actions accoring to the current application state
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

		var shortcutItems = [UIApplicationShortcutItem(type: QuickAction.diaryNewEntry.rawValue, localizedTitle: AppStrings.QuickActions.contactDiaryNewEntry, localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "book.closed"))]
		
		let status = AVCaptureDevice.authorizationStatus(for: .video)
		if status == .authorized || status == .notDetermined {
			// dont show event checkin action if no camera access granted
			shortcutItems.append(
				UIApplicationShortcutItem(type: QuickAction.eventCheckin.rawValue, localizedTitle: AppStrings.QuickActions.eventCheckin, localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "qrcode.viewfinder"))
			)
		}
		
		application.shortcutItems = shortcutItems
	}
}

extension AppDelegate {

	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		handleShortcutItem(shortcutItem)
	}

	/// Checks wether the application is launched from a shortcut or not.
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
		case QuickAction.diaryNewEntry.rawValue:
			Log.info("Shortcut: Open new diary entry", log: .ui)
			guard let tabBarController = coordinator.tabBarController else { return }
			tabBarController.selectedIndex = 2

			// dismiss an overlaying, modally presented view controller
			coordinator.diaryCoordinator?.viewController.presentedViewController?.dismiss(animated: false, completion: nil)

			// let diary coordinator handle pre-checks & navigation
			coordinator.diaryCoordinator?.showCurrentDayScreen()
		case QuickAction.eventCheckin.rawValue:
			Log.info("Shortcut: Event checkin 📷", log: .ui)
			guard let tabBarController = coordinator.tabBarController else { return }
			tabBarController.selectedIndex = 1
			
			// dismiss an overlaying, modally presented view controller
			coordinator.checkInCoordinator?.viewController.presentedViewController?.dismiss(animated: false, completion: nil)
			
			// open qr code scanner for fast event checkin
			coordinator.checkInCoordinator?.showQRCodeScanner()
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
