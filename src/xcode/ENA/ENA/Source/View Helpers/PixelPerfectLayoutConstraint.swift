//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

@IBDesignable
class PixelPerfectLayoutConstraint: NSLayoutConstraint {
	@IBInspectable var pixelPerfectConstant: CGFloat = -1

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		applyPixelPerfectConstant()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		applyPixelPerfectConstant()
	}

	private func applyPixelPerfectConstant() {
		if pixelPerfectConstant > 0 {
			constant = pixelPerfectConstant
		}

		if let window = (firstItem as? UIView)?.window {
			constant /= window.screen.scale
		} else {
			constant /= UIScreen.main.scale
		}
	}
}
