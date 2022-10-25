//
// 🦠 Corona-Warn-App
//

import UIKit

extension String {
	func withHyhenationStyle(factor: Float = 0.8) -> NSAttributedString {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.hyphenationFactor = factor
		
		return NSAttributedString(
			string: self,
			attributes: [
				.paragraphStyle: paragraphStyle
			]
		)
	}
}
