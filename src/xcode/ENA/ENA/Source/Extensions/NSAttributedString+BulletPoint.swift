////
// 🦠 Corona-Warn-App
//

import UIKit

extension NSAttributedString {

	/// Prefixes an attributed string with a bullet point (\u{2022}).
	///
	///  Line breaks will add further bullet points, tabs on line-start (`\t`) will not. Example:
	///  `"TEXT_A\n\tTEXT_B"` would create a 2 paragraph text with one bullet point.
	///
	/// - Parameters:
	///   - from: The initial attributed string.
	///   - bulletPointFont: The Font for the bullet point and first part of the `from` string. Required to align and scale the bullet point.
	/// - Returns: An attributed string that is prefixed with a bullet point.
	static func bulletPointString(_ from: NSAttributedString, bulletPointFont font: UIFont, bulletPointColor color: UIColor = .enaColor(for: ENAColor.textPrimary1)) -> NSAttributedString {
		// <bullet point>|--- indentation ---|<rest of text>
		let indentation: CGFloat = 20.0
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.tabStops = [NSTextTab(textAlignment: .natural, location: indentation, options: [:])]
		paragraphStyle.defaultTabInterval = indentation
		paragraphStyle.headIndent = indentation
		paragraphStyle.paragraphSpacing = 8

		let bulletAttributes: [NSAttributedString.Key: Any] = [
			.font: font.scaledFont(size: font.pointSize, weight: .black),
			.foregroundColor: color
		]

		let bullet = "\u{2022}"
		let prefixString = "\(bullet)\t"

		let attributedString = NSMutableAttributedString(string: prefixString)
		attributedString.append(from)

		// style bullet point
		let string = NSString(string: prefixString)
		let rangeForBullet = string.range(of: bullet)
		attributedString.addAttributes(bulletAttributes, range: rangeForBullet)

		// style text paragraphs
		attributedString.addAttributes(
			[NSAttributedString.Key.paragraphStyle: paragraphStyle],
			range: NSRange(location: 0, length: attributedString.length))

		return attributedString
	}

	/// Prefixes an attributed string with a bullet point (\u{2022}).
	///
	///  Line breaks will add further bullet points, tabs (`\t`) will not.
	///
	/// - Parameters:
	///   - bulletPointFont: The Font for the bullet point and first part of the `from` string. Required to align and scale the bullet point.
	/// - Returns: An attributed string that is prefixed with a bullet point.
	func bulletPointString(bulletPointFont font: UIFont) -> NSAttributedString {
		return NSAttributedString.bulletPointString(self, bulletPointFont: font)
	}
	
	func bulletPointString(bulletPointFont font: UIFont, bulletPointColor: UIColor) -> NSAttributedString {
		return NSAttributedString.bulletPointString(self, bulletPointFont: font, bulletPointColor: bulletPointColor)
	}
}
