//
// 🦠 Corona-Warn-App
//

import Foundation

extension NSMutableAttributedString {

	/// Generates an attributed string from a normal text + attributed text injected into this text.
	static func generateAttributedString(normalText: String, attributedText: [NSAttributedString]) -> NSMutableAttributedString {
		let components = normalText.components(separatedBy: "%@")
		let adjusted: NSMutableAttributedString = NSMutableAttributedString(string: "")

		for (index, element) in components.enumerated() {
			adjusted.append(NSAttributedString(string: element))
			if index < attributedText.count {
				adjusted.append(attributedText[index])
			}
		}

		return adjusted
	}
}
