//
// 🦠 Corona-Warn-App
//

import UIKit

extension UIWindow {
	var visibleViewController: UIViewController? {
		return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
	}

	static func getVisibleViewControllerFrom(_ viewController: UIViewController?) -> UIViewController? {
		if let navigationController = viewController as? UINavigationController {
			return UIWindow.getVisibleViewControllerFrom(navigationController.visibleViewController)
		} else if let tabBarController = viewController as? UITabBarController {
			return UIWindow.getVisibleViewControllerFrom(tabBarController.selectedViewController)
		} else {
			if let presentedViewController = viewController?.presentedViewController {
				return UIWindow.getVisibleViewControllerFrom(presentedViewController)
			} else {
				return viewController
			}
		}
	}
}
