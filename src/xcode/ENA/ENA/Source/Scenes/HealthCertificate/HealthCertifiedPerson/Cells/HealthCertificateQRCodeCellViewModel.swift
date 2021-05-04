////
// 🦠 Corona-Warn-App
//

import UIKit

struct HealthCertificateQRCodeCellViewModel {

	// MARK: - Init

	init(
		backgroundColor: UIColor,
		borderColor: UIColor
	) {
		self.backgroundColor = backgroundColor
		self.borderColor = borderColor
	}

	// MARK: - Internal

	let backgroundColor: UIColor
	let borderColor: UIColor

	// QRCode image with data inside
	func qrCodeImage(revDate: Date = Date()) -> UIImage {
		guard let QRCodeImage = UIImage.qrCode(
			with: "This is just a test content for the wonderful new QR Code",
			encoding: .utf8,
			size: CGSize(width: 280.0, height: 280.0),
			qrCodeErrorCorrectionLevel: .medium
		)
		else {
			Log.error("Failed to create QRCode image for vCard data")
			return UIImage()
		}
		return QRCodeImage
	}
}
