//
// 🦠 Corona-Warn-App
//

import UIKit

extension UIView {
	/// Sets `translatesAutoresizingMaskIntoConstraints` to a specific `state` for all views.
	static func translatesAutoresizingMaskIntoConstraints(for views: [UIView], to _: Bool) {
		views.forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
	}

	/// Adds the specified subviews to self.
	func addSubviews(_ views: [UIView]) {
		views.forEach { subView in
			self.addSubview(subView)
		}
	}
}
