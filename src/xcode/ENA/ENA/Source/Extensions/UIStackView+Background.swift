//
// 🦠 Corona-Warn-App
//

import UIKit

extension UIStackView {
	func add(backgroundColor: UIColor) {
		let viewWithBackgroundColor = UIView(frame: .zero)
		viewWithBackgroundColor.translatesAutoresizingMaskIntoConstraints = false
		viewWithBackgroundColor.backgroundColor = backgroundColor
		insertSubview(viewWithBackgroundColor, at: 0)
		
		NSLayoutConstraint.activate([
			viewWithBackgroundColor.leadingAnchor.constraint(equalTo: leadingAnchor),
			viewWithBackgroundColor.topAnchor.constraint(equalTo: topAnchor),
			viewWithBackgroundColor.trailingAnchor.constraint(equalTo: trailingAnchor),
			viewWithBackgroundColor.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
}
