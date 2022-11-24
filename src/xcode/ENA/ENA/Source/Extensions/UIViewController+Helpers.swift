//
// 🦠 Corona-Warn-App
//

import UIKit

extension UIViewController {
	func dismissAllModalViewControllers(animated: Bool, completion: CompletionVoid? = nil) {
		view.window?.rootViewController?.dismiss(
			animated: animated,
			completion: completion
		)
	}
}
