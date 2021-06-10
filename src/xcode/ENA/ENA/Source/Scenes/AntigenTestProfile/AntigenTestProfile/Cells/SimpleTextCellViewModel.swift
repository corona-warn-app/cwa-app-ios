////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct SimpleTextCellViewModel {

	// MARK: - Init

	init(
		backgroundColor: UIColor?,
		textColor: UIColor? = nil,
		textAlignment: NSTextAlignment? = nil,
		text: String? = nil,
		attributedText: NSAttributedString? = nil,
		topSpace: CGFloat,
		font: UIFont,
		borderColor: UIColor = .clear,
		accessibilityTraits: UIAccessibilityTraits = .none
	) {
		self.backgroundColor = backgroundColor
		self.textColor = textColor
		self.textAlignment = textAlignment ?? .center
		self.text = text
		self.attributedText = attributedText
		self.topSpace = topSpace
		self.font = font
		self.borderColor = borderColor
		self.accessibilityTraits = accessibilityTraits
	}

	// MARK: - Internal

	let backgroundColor: UIColor?
	let textColor: UIColor?
	let textAlignment: NSTextAlignment
	let text: String?
	let attributedText: NSAttributedString?
	let topSpace: CGFloat
	let font: UIFont
	let borderColor: UIColor
	let accessibilityTraits: UIAccessibilityTraits

}
