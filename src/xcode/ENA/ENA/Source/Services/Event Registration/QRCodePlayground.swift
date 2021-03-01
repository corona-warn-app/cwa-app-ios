////
// 🦠 Corona-Warn-App
//

import UIKit
import Base32

enum QRCodePlayground {
	
	static func generateQRCode(with string: String) -> UIImage? {
//		guard let cgImage = EFQRCode.generate(content: string, contentEncoding: .isoLatin1, size: .init(width: 400, height: 400), inputCorrectionLevel: .h) else {
//			return nil
//		}
//		return UIImage(cgImage: cgImage)
//		let smollData = String(string, radix: 8)
//		let data = string.data(using: .isoLatin1)
//		let encoded = String(1000, radix: 16)
//		print(encoded)
		let targetSize = CGSize(width: 400, height: 400)
		
		guard let data = string.data(using: .shiftJIS) else {
			return nil
		}
		let filter = CIFilter(name: "CIQRCodeGenerator")
		filter?.setValue(data, forKey: "inputMessage")
		filter?.setValue("H", forKey: "inputCorrectionLevel")

		guard let image = filter?.outputImage else {
			return nil
		}
		
		
		
		let scaleX = targetSize.width / image.extent.size.width
		let scaleY = targetSize.height / image.extent.size.height
		
		let transformedImage = image.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
		
		
		return UIImage(ciImage: transformedImage)
	
	}
}
