//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class Tracelocation_GenerateQRCodeTests: XCTestCase {
	
	func testQRCodeGeneration() throws {
		let stringToEncode = "HTTPS://CORONAWARN.APP/E1/BIPEY33SMVWSA2LQON2W2IDEN5WG64RAONUXIIDBNVSXILBAMNXRBCM4UQARRKM6UQASAHRKCC7CTDWGQ4JCO7RVZSWVIMQK4UPA.GBCAEIA7TEORBTUA25QHBOCWT26BCA5PORBS2E4FFWMJ3UU3P6SXOL7SHUBCA7UEZBDDQ2R6VRJH7WBJKVF7GZYJA6YMRN27IPEP7NKGGJSWX3XQ"
		
		let qrCodeImage = try XCTUnwrap(QRCodePlayground.generateQRCode(with: stringToEncode))
		
		let decodedString = extractFirstMessageFrom(qrCode: qrCodeImage)
		
		XCTAssertEqual(qrCodeImage.size.height, qrCodeImage.size.width)
		XCTAssertEqual(qrCodeImage.size.height, 400)
		XCTAssertEqual(stringToEncode, decodedString)
	}
	
	
	func testQRCodeGenerationWithCustomSize() throws {
		
		let stringToEncode = "HTTPS://CORONAWARN.APP/E1/BIPEY33SMVWSA2LQON2W2IDEN5WG64RAONUXIIDBNVSXILBAMNXRBCM4UQARRKM6UQASAHRKCC7CTDWGQ4JCO7RVZSWVIMQK4UPA.GBCAEIA7TEORBTUA25QHBOCWT26BCA5PORBS2E4FFWMJ3UU3P6SXOL7SHUBCA7UEZBDDQ2R6VRJH7WBJKVF7GZYJA6YMRN27IPEP7NKGGJSWX3XQ"

		let qrCodeImage = try XCTUnwrap(QRCodePlayground.generateQRCode(with: stringToEncode, size: CGSize(width: 1000, height: 1000)))
		
		let decodedString = extractFirstMessageFrom(qrCode: qrCodeImage)

		XCTAssertEqual(qrCodeImage.size.height, qrCodeImage.size.width)
		XCTAssertEqual(qrCodeImage.size.height, 1000)
		XCTAssertEqual(stringToEncode, decodedString)
	}
	
	
	func extractFirstMessageFrom(qrCode: UIImage) -> String? {
		if let ciImage = qrCode.ciImage {
			var options: [String: Any]
			let context = CIContext()
			options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
			let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
			if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)) {
				options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
			} else {
				options = [CIDetectorImageOrientation: 1]
			}
			let features = qrDetector?.features(in: ciImage, options: options)
			let firstFeature = features?.first as? CIQRCodeFeature
			return firstFeature?.messageString
		}
		return nil
	}
	
}
