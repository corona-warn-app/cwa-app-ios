////
// 🦠 Corona-Warn-App
//

import UIKit

// stolen from: https://gist.github.com/Deub27/5eadbf1b77ce28abd9b630eadb95c1e2
extension UIStackView {


	/// Removes ALL arranged subviews from a `UIStackView` and disables any constraints on these views before releasing them finally.
	///
	/// There [was debate](https://stackoverflow.com/questions/37525706/uistackview-is-it-really-necessary-to-call-both-removefromsuperview-and-remove) if this is necessary. We haven't tested this further and go safe by being explicit.
	func removeAllArrangedSubviews() {
		let removedSubviews = arrangedSubviews.reduce([]) { allSubviews, subview -> [UIView] in
			self.removeArrangedSubview(subview)
			return allSubviews + [subview]
		}

		// Deactivate all constraints
		NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))

		// Remove the views from self
		removedSubviews.forEach({ $0.removeFromSuperview() })
	}
	
	func forceLayoutUpdate() {
		// hiding a stack views subview forces the stack view to update its layout
		// this is how we solve the layout bug when reusing stack views in table view cells
		arrangedSubviews.forEach({ $0.isHidden = true })
		setNeedsLayout()
		layoutIfNeeded()
		arrangedSubviews.forEach({ $0.isHidden = false })
	}
}
