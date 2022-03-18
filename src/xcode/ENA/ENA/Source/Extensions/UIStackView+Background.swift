//
// 🦠 Corona-Warn-App
//

import UIKit

extension UIStackView {
	func add(backgroundColor: UIColor) {
		let additionalBackground = UIView(frame: bounds)
		additionalBackground.backgroundColor = backgroundColor
		additionalBackground.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		insertSubview(additionalBackground, at: 0)
	}
}
