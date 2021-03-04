////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

extension UIImage {

	/// Resize and create a new UIImage with targetSize and keep the aspect ratio of the original image
	func resize(with targetSize: CGSize) -> UIImage {
		// store width and height ration
		let widthRatio = targetSize.width / self.size.width
		let heightRatio = targetSize.height / self.size.height

		// determine the scale factor and real size
		let scaleFactor = min(widthRatio, heightRatio)
		let scaledImageSize = CGSize(
			width: self.size.width * scaleFactor,
			height: self.size.height * scaleFactor
		)

		let renderer = UIGraphicsImageRenderer(size: targetSize)
		return renderer.image { _ in
			self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
		}
	}

}
