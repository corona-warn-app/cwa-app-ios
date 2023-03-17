//
// 🦠 Corona-Warn-App
//

import Foundation

extension NSMutableAttributedString {

	/// looks for the given text and sets a link attribute
	public func mark(_ text: String, with link: String) {
		let foundRange = mutableString.range(of: text)
		
		guard let linkURL = URL(string: link) else {
			Log.debug("Link URL could not created from string: \(link).")
			return
		}
		
		guard foundRange.location != NSNotFound else {
			Log.debug("Link \(text) text not found.")
			return
		}

		addAttributes([NSAttributedString.Key.link: linkURL], range: foundRange)
	}
}
