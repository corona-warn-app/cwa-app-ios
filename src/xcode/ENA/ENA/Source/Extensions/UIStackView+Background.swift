//
// 🦠 Corona-Warn-App
//

import UIKit

extension UIStackView {
	func add(backgroundColor: UIColor) {
		let viewWithBackgroundColor = UIView(frame: bounds)
		viewWithBackgroundColor.backgroundColor = backgroundColor
		insertSubview(viewWithBackgroundColor, at: 0)

		translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			viewWithBackgroundColor.topAnchor.constraint(equalTo: topAnchor),
			viewWithBackgroundColor.leadingAnchor.constraint(equalTo: leadingAnchor),
			viewWithBackgroundColor.trailingAnchor.constraint(equalTo: trailingAnchor),
			viewWithBackgroundColor.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
}
