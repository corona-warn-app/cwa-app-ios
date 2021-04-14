//
// 🦠 Corona-Warn-App
//

import UIKit

@IBDesignable
final class QRScannerFocusView: UIView {
	@IBInspectable var backdropOpacity: CGFloat = 0
	@IBInspectable var cornerRadius: CGFloat = 0
	@IBInspectable var borderWidth: CGFloat = 1

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()

		backgroundColor = UIColor(white: 1, alpha: 0.5)

		awakeFromNib()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		configure(cornerRadius: cornerRadius, borderWidth: borderWidth)
	}
	
	func configure(cornerRadius: CGFloat, borderWidth: CGFloat) {
		layer.cornerRadius = cornerRadius
		layer.borderWidth = borderWidth
		layer.borderColor = tintColor.cgColor
	}
}
