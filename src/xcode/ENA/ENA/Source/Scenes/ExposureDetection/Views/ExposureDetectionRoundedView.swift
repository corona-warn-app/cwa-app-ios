//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

@IBDesignable
class ExposureDetectionRoundedView: UIView {
	override var bounds: CGRect {
		didSet {
			applyRoundedCorners()
		}
	}

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		applyRoundedCorners()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		applyRoundedCorners()

		backgroundColor = UIColor.enaColor(for: .textPrimary1Contrast).withAlphaComponent(0.1)
	}

	private func applyRoundedCorners() {
		layer.cornerRadius = min(bounds.width, bounds.height) / 2
	}
}
