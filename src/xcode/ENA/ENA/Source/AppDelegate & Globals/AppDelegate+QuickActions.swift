////
// 🦠 Corona-Warn-App
//

import UIKit

// MARK: - Quick Actions

extension AppDelegate {

	/// General identifier for the 'add diary entry' shortcut action
	private static let shortcutIdDiaryNewEntry = "de.rki.coronawarnapp.shortcut.diarynewentry"

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

	func setupQuickActions() {
		// register for special events in the app flow
		_ = NotificationCenter.default.addObserver(forName: .didStartExposureSubmissionFlow, object: nil, queue: nil) { [weak self] notification in
			// don't allow shortcut during the more important submission flow
			// but only if there is a positive test result
			if let resultValue = notification.userInfo?["result"] as? Int, let result = TestResult(rawValue: resultValue) {
				self?.updateQuickActions(removeAll: result == .positive)
			} else if notification.userInfo?["result"] as? Int == -1 {
				// not sure if this is happening only when using launch arguments, but because we end up in the 'positive' flow,
				// we'll better disable the shortcuts
				self?.updateQuickActions(removeAll: true)
			} else {
				self?.updateQuickActions()
			}
		}
		_ = NotificationCenter.default.addObserver(forName: .didDismissExposureSubmissionFlow, object: nil, queue: nil) { [weak self] _ in
			self?.updateQuickActions()
		}

		// define initial set of actions
		updateQuickActions()
	}

	/// Adds or removes quick actions accoring to the current application state
	func updateQuickActions(removeAll: Bool = false) {
		Log.info("\(#function) removeAll: \(removeAll)", log: .ui)

		let application = UIApplication.shared
		// No shortcuts if not onboarded
		guard store.isOnboarded, !removeAll else {
			application.shortcutItems = nil
			return
		}

		application.shortcutItems = [
			UIApplicationShortcutItem(type: AppDelegate.shortcutIdDiaryNewEntry, localizedTitle: AppStrings.QuickActions.contactDiaryNewEntry, localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "book.closed"))
		]
	}


	/// General handler for all shortcut items.
	///
	///  Currently implemented:
	///   - New Dictionary Entry
	///
	/// - Parameter shortcutItem: the item to launch
	func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
		Log.debug("Did open app via shortcut \(shortcutItem.type)", log: .ui)
		if shortcutItem.type == AppDelegate.shortcutIdDiaryNewEntry {
			Log.info("Shortcut: Open new diary entry", log: .ui)
			guard let tabBarController = coordinator.tabBarController else { return }
			tabBarController.selectedIndex = 1
			
			// dismiss an overlaying, modally presented view controller
			coordinator.diaryCoordinator?.viewController.presentedViewController?.dismiss(animated: false, completion: nil)

			// let diary coordinator handle pre-checks & navigation
			coordinator.diaryCoordinator?.showCurrentDayScreen()
		}
	}
}

extension RootCoordinator {

	/// Direct access to the tabbar controller
	fileprivate var tabBarController: UITabBarController? {
		viewController.children.compactMap({ $0 as? UITabBarController }).first
	}
}
