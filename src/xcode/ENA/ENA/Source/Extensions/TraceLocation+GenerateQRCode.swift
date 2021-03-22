////
// 🦠 Corona-Warn-App
//

import UIKit
import Base32

extension TraceLocation {
	func generateQRCode(with string: String, size: CGSize = CGSize(width: 400, height: 400)) -> UIImage? {

		/// Create data from string which will be feed into the CoreImage Filter
		guard let data = string.data(using: .shiftJIS) else {
			return nil
		}
		
		/// Create CoreImage Filter to create QR-Code
		guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
			return nil
		}
		filter.setValue(data, forKey: "inputMessage") /// Feed data into Filter
		filter.setValue("H", forKey: "inputCorrectionLevel") /// Set ErrorCorrectionLevel

		guard let image = filter.outputImage else {
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
	
	func generateQRCode(size: CGSize = CGSize(width: 400, height: 400)) -> UIImage? {

		/// Create data from string which will be feed into the CoreImage Filter
		guard let data = qrCodeURL.data(using: .shiftJIS) else {
			return nil
		}
		
		/// Create CoreImage Filter to create QR-Code
		guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
			return nil
		}
		filter.setValue(data, forKey: "inputMessage") /// Feed data into Filter
		filter.setValue("H", forKey: "inputCorrectionLevel") /// Set ErrorCorrectionLevel

		guard let image = filter.outputImage else {
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
