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
			// Instead of blocking the thread we'll delay the handling for the shortcut item
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
				self.handleShortcutItem(shortcutItem)
			}

			// prevents triggering `application(_:performActionFor:completionHandler:)`
			// see: https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622935-application
			return false
		}
		return true
	}

	func setupQuickActions() {
		let application = UIApplication.shared
		guard store.isOnboarded else {
			application.shortcutItems = nil
			return
		}

		application.shortcutItems = [
			UIApplicationShortcutItem(type: AppDelegate.shortcutIdDiaryNewEntry, localizedTitle: AppStrings.QuickActions.contactDiaryNewEntry, localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "book.closed"))
		]
	}

	func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
		Log.debug("Did open app via shortcut \(shortcutItem.type)", log: .ui)
		if shortcutItem.type == AppDelegate.shortcutIdDiaryNewEntry {
			Log.info("Shortcut: Open new diary entry", log: .ui)
			guard let tabBarController = coordinator.tabBarController else { return }
			tabBarController.selectedIndex = 1

			// let diary coordinator handle navigation
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
