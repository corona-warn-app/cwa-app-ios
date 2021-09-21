//
// 🦠 Corona-Warn-App
//

import UIKit

/* The navigation bar of this controller is pre-configured with a value for mixed operation of view controllers with large
   and with normal titles. This property of the shared navigation bar needs not be re-configured at runtime. */
class NavigationControllerWithLargeTitle: UINavigationController {

	// MARK: - Init

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	// MARK: - Overrides

	override init(rootViewController: UIViewController) {
		if #available(iOS 13.0, *) {
			super.init(rootViewController: rootViewController)
		} else {
			super.init(nibName: nil, bundle: nil)
			self.viewControllers = [rootViewController]
		}
		setup()
	}

	// MARK: - Private
	
	private func setup() {
		navigationBar.prefersLargeTitles = true
	}
}
