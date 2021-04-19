//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

extension UIFont {
	var textStyle: UIFont.TextStyle? {
		guard let string = fontDescriptor.fontAttributes[.textStyle] as? String else { return nil }
		return UIFont.TextStyle(rawValue: string)
	}

	func scaledFont(size: CGFloat? = nil, weight: Weight? = .regular, italic: Bool = false) -> UIFont {
		guard let textStyle = self.textStyle else { return self }

		let metrics = UIFontMetrics(forTextStyle: textStyle)
		let description = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
		let systemFont = UIFont.systemFont(ofSize: size ?? description.pointSize, weight: weight ?? .regular)
		let font = metrics.scaledFont(for: systemFont)

		if italic,
		   let italicFontDescriptor = font.fontDescriptor.withSymbolicTraits(.traitItalic) {
			return UIFont(descriptor: italicFontDescriptor, size: 0)
		} else {
			return font
		}
	}
}

extension UIFont.Weight {
	init(_ string: String?) {
		let weights: [String: UIFont.Weight] = [
			"ultraLight": .ultraLight,
			"thin": .thin,
			"light": .light,
			"regular": .regular,
			"medium": .medium,
			"semibold": .semibold,
			"bold": .bold,
			"heavy": .heavy,
			"black": .black
		]
		self.init(rawValue: weights[string ?? "regular"]?.rawValue ?? UIFont.Weight.regular.rawValue)
	}
}
