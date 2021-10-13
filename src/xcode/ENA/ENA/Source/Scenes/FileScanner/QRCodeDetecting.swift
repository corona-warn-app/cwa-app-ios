//
// 🦠 Corona-Warn-App
//

import UIKit

protocol QRCodeDetecting {
	func findQRCodes(in image: UIImage) -> [String]?
}

class QRCodeDetector: QRCodeDetecting {

	// MARK: - Init

	// MARK: - Protocol QRCodeDetector

	func findQRCodes(in image: UIImage) -> [String]? {
		guard let features = detectQRCode(image) else {
			Log.debug("no features found in image", log: .fileScanner)
			return nil
		}
		return features.compactMap { $0 as? CIQRCodeFeature }
		.compactMap { $0.messageString }
	}

	// MARK: - Private

	private func detectQRCode(_ image: UIImage) -> [CIFeature]? {
		guard let ciImage = CIImage(image: image) else {
			return nil
		}
		let context = CIContext()
		// we can try to use CIDetectorAccuracyLow to speedup things a bit here
		let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
		let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
		let features = qrDetector?.features(in: ciImage, options: options)
		return features
	}

}
