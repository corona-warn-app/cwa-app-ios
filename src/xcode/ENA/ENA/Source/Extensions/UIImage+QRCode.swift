////
// 🦠 Corona-Warn-App
//

import UIKit

extension UIImage {

	class func qrCode(
		with string: String,
		encoding: String.Encoding = .shiftJIS,
		size: CGSize = CGSize(width: 400, height: 400),
		qrCodeErrorCorrectionLevel: MappedErrorCorrectionType = .medium
	) -> UIImage? {
		/// Create data from string which will be feed into the CoreImage Filter
		guard let data = string.data(using: encoding) else {
			Log.error("Failed to convert string to data", log: .qrCode)
			return nil
		}

		/// Create CoreImage Filter to create QR-Code
		guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
			Log.error("Failed to get CIFilter CIQRCodeGenerator", log: .qrCode)
			return nil
		}
		filter.setValue(data, forKey: "inputMessage") /// Feed data into Filter
		filter.setValue(qrCodeErrorCorrectionLevel.mappedValue, forKey: "inputCorrectionLevel") /// Set ErrorCorrectionLevel

		guard let image = filter.outputImage else {
			Log.error("Failed to get output image from filter", log: .qrCode)
			return nil
		}

		/// Depending on the length of the string the QRCode may vary in size. But we want an Image with a fixed size. This requires us to scale the QRCode to our desired image size.
		/// Calculate scaling factors
		let scaleX = size.width / image.extent.size.width
		let scaleY = size.height / image.extent.size.height

		/// Scale image
		let transformedImage = image.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

		/// Return scaled image
		return UIImage(ciImage: transformedImage)
	}

}
