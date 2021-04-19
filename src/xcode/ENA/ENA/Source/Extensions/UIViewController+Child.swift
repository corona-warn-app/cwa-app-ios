//
// 🦠 Corona-Warn-App
//

import UIKit

extension UIViewController {
	
	func clearChildViewController() {
		for childVC in children {
			childVC.willMove(toParent: nil)
			childVC.view.removeFromSuperview()
			childVC.removeFromParent()
		}
	}
	
	func embedViewController(childViewController: UIViewController) {
		view.addSubview(childViewController.view)
		addChild(childViewController)
		childViewController.didMove(toParent: self)
	}
}
