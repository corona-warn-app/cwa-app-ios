////
// 🦠 Corona-Warn-App
//

import UIKit

extension TraceLocation {

	// MARK: - Internal
	
	func uiImageQRCode(
		size: CGSize = CGSize(width: 400, height: 400),
		scale: CGFloat = UIScreen.main.scale,
		qrCodeErrorCorrectionLevel: MappedErrorCorrectionType = .medium
	) -> UIImage? {
		guard let qrCodeURL = qrCodeURL else {
			return nil
		}

		return UIImage.qrCode(
			with: qrCodeURL,
			size: size,
			scale: scale,
			qrCodeErrorCorrectionLevel: qrCodeErrorCorrectionLevel
		)
	}

	func ciImageQRCode(
		size: CGSize = CGSize(width: 400, height: 400),
		scale: CGFloat,
		qrCodeErrorCorrectionLevel: MappedErrorCorrectionType = .medium
	) -> CIImage? {
		guard let qrCodeURL = qrCodeURL else {
			return nil
		}

		return CIImage.qrCode(
			with: qrCodeURL,
			size: size,
			scale: scale,
			qrCodeErrorCorrectionLevel: qrCodeErrorCorrectionLevel
		)
	}

}
