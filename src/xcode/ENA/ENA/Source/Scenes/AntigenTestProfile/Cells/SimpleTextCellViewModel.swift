////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct SimpleTextCellViewModel {


	// MARK: - Init

	init(
		backgroundColor: UIColor?,
		textColor: UIColor,
		textAlignment: NSTextAlignment,
		text: String,
		topSpace: CGFloat,
		font: UIFont,
		boarderColor: UIColor = .clear
	) {
		self.backgroundColor = backgroundColor
		self.textColor = textColor
		self.textAlignment = textAlignment
		self.text = text
		self.topSpace = topSpace
		self.font = font
		self.boarderColor = boarderColor
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	let backgroundColor: UIColor?
	let textColor: UIColor
	let textAlignment: NSTextAlignment
	let text: String
	let topSpace: CGFloat
	let font: UIFont
	let boarderColor: UIColor

	// MARK: - Private

}
