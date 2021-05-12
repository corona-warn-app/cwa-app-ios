////
// 🦠 Corona-Warn-App
//

import UIKit

struct HealthCertificateQRCodeCellViewModel {

	// MARK: - Init

	init(
		healthCertificate: HealthCertificate
	) {
		self.healthCertificate = healthCertificate
		self.certificate = "Impfzertifikat 2 von 2"
		self.validity = "Geimpft 24.04.21 - gültig bis 24.04.22"
	}

	// MARK: - Internal

	let backgroundColor: UIColor = .enaColor(for: .background)
	let borderColor: UIColor = .enaColor(for: .hairline)
	let certificate: String
	let validity: String

	// QRCode image with data inside
	func qrCodeImage(revDate: Date = Date()) -> UIImage {
		guard let QRCodeImage = UIImage.qrCode(
			with: healthCertificate.base45,
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

	let healthCertificate: HealthCertificate

}
