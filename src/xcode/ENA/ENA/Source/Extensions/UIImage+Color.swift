//
// 🦠 Corona-Warn-App
//

import UIKit

extension UIImage {

	static func with(color: UIColor) -> UIImage? {
		let rect = CGRect(x: 0, y: 0, width: 1, height: 1)

		UIGraphicsBeginImageContext(rect.size)

		if let context = UIGraphicsGetCurrentContext() {
			context.setFillColor(color.cgColor)
			context.fill(rect)
		}

		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return image
	}

}
