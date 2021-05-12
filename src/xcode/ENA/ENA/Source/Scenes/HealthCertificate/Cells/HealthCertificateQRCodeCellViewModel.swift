////
// 🦠 Corona-Warn-App
//

import UIKit

struct HealthCertificateQRCodeCellViewModel {

	// MARK: - Init

	init(
		proofCertificate: ProofCertificate
	) {
		self.proofCertificate = proofCertificate
	}

	// MARK: - Internal

	let backgroundColor: UIColor = .enaColor(for: .background)
	let borderColor: UIColor = .enaColor(for: .hairline)

	// QRCode image with data inside
	func qrCodeImage(revDate: Date = Date()) -> UIImage {
		guard let QRCodeImage = UIImage.qrCode(
			with: proofCertificate.base45,
			encoding: .utf8,
			size: CGSize(width: 280.0, height: 280.0),
			qrCodeErrorCorrectionLevel: .medium
		)
		else {
			Log.error("Failed to create QRCode image for proof certificate")
			return UIImage()
		}
		return QRCodeImage
	}

	// MARK: - Private

	let proofCertificate: ProofCertificate

}
