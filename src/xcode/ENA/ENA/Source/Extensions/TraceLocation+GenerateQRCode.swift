////
// 🦠 Corona-Warn-App
//

import UIKit

extension TraceLocation {

	// MARK: - Internal
	
	func qrCode(size: CGSize = CGSize(width: 400, height: 400), qrCodeErrorCorrectionLevel: MappedErrorCorrectionType = .medium) -> UIImage? {
		guard let qrCodeURL = qrCodeURL else {
			return nil
		}

		return UIImage.QRCode(with: qrCodeURL, size: size, qrCodeErrorCorrectionLevel: qrCodeErrorCorrectionLevel)
	}

}
