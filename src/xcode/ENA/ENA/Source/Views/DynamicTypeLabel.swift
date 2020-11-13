//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

@IBDesignable
class DynamicTypeLabel: UILabel {
	@IBInspectable var dynamicTypeSize: CGFloat = 0 { didSet { applyDynamicFont() } }
	@IBInspectable var dynamicTypeWeight: String = "" {
		didSet { applyDynamicFont() }
	}

	private var rawFont: UIFont!

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		applyDynamicFont()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		applyDynamicFont()
	}

	private func applyDynamicFont() {
		if rawFont == nil { rawFont = self.font }

		guard let textStyle = rawFont.textStyle else { return }

		adjustsFontForContentSizeCategory = true

		let weight = dynamicTypeWeight.isEmpty ? nil : dynamicTypeWeight
		let size = dynamicTypeSize > 0 ? dynamicTypeSize : nil

		guard weight != nil || size != nil else { return }

		let metrics = UIFontMetrics(forTextStyle: textStyle)
		let description = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
		let systemFont = UIFont.systemFont(ofSize: size ?? description.pointSize, weight: UIFont.Weight(weight))
		let font = metrics.scaledFont(for: systemFont)

		self.font = font
	}
}
