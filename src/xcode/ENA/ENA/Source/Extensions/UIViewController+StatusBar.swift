//
// 🦠 Corona-Warn-App
//

import UIKit

extension UIViewController {
	
	func setupStatusBarViewBackgroundColorIfNeeded() {
		guard #available(iOS 13, *) else {
			guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
				return
			}
			statusBarView.backgroundColor = .white
			return
		}
	}
		
	func revertStatusBarViewBackgroundColorIfNeeded() {
		guard #available(iOS 13, *) else {
			guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
				return
			}
			statusBarView.backgroundColor = .clear
			return
		}
	}

}
