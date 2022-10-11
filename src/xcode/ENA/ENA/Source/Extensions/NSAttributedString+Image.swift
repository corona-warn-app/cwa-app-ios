//
// 🦠 Corona-Warn-App
//

import UIKit

extension NSAttributedString {
	var attachementImage: UIImage? {
		var image: UIImage?

		self.enumerateAttribute(.attachment, in: NSRange(location: 0, length: self.length)) { value, _, _ in
			if let attachment = value as? NSTextAttachment {
				image = attachment.image
			}
		}

		return image
	}
}
