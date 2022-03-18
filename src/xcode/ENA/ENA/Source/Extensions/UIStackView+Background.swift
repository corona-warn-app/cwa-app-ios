//
// 🦠 Corona-Warn-App
//

import UIKit

extension UIStackView {
	func add(backgroundColor: UIColor) {
		let viewWithBackgroundColor = UIView(frame: bounds)
		viewWithBackgroundColor.backgroundColor = backgroundColor
		insertSubview(viewWithBackgroundColor, at: 0)
	}
}
