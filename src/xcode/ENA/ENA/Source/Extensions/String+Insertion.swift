//
// 🦠 Corona-Warn-App
//

import UIKit

extension String {

	/// Returns an attributed string that inserts the given string in an emphasized style
	func inserting(emphasizedString: String) -> NSAttributedString {
		return NSMutableAttributedString.generateAttributedString(normalText: self, attributedText: [
			NSAttributedString(string: emphasizedString, attributes: [
				NSAttributedString.Key.font: UIFont.enaFont(for: .headline)
			])
		])
	}

}
