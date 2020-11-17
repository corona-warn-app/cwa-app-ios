//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

@IBDesignable
class DynamicTypeButton: UIButton {
	@IBInspectable var cornerRadius: CGFloat = 8 { didSet { self.layer.cornerRadius = cornerRadius } }
	@IBInspectable var dynamicTypeSize: CGFloat = 0 { didSet { applyDynamicFont() } }
	@IBInspectable var dynamicTypeWeight: String = "" { didSet { applyDynamicFont() } }

	private var rawFont: UIFont!

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}

	private func setup() {
		layer.cornerRadius = cornerRadius

		applyDynamicFont()
	}

	private func applyDynamicFont() {
		guard let titleLabel = self.titleLabel else { return }
		if rawFont == nil { rawFont = titleLabel.font }

		guard let textStyle = rawFont.textStyle else { return }

		titleLabel.adjustsFontForContentSizeCategory = true

		let weight = dynamicTypeWeight.isEmpty ? nil : dynamicTypeWeight
		let size = dynamicTypeSize > 0 ? dynamicTypeSize : nil

		guard weight != nil || size != nil else { return }

		let metrics = UIFontMetrics(forTextStyle: textStyle)
		let description = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
		let systemFont = UIFont.systemFont(ofSize: size ?? description.pointSize, weight: UIFont.Weight(weight))
		let font = metrics.scaledFont(for: systemFont)

		titleLabel.font = font
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		titleLabel?.sizeToFit()
	}
}
