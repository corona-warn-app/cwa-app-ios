//
// 🦠 Corona-Warn-App
//

import UIKit


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
