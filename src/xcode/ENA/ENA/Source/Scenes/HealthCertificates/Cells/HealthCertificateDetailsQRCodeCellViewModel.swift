////
// 🦠 Corona-Warn-App
//

import UIKit

struct HealthCertificateDetailsQRCodeCellViewModel {

	// MARK: - Init

	init(
		healthCertificate: HealthCertificate,
		accessibilityText: String?
	) {
		let qrCodeSize = UIScreen.main.bounds.width - 60

		self.qrCodeImage = UIImage.qrCode(
			with: healthCertificate.base45,
			encoding: .utf8,
			size: CGSize(width: qrCodeSize, height: qrCodeSize),
			qrCodeErrorCorrectionLevel: .quartile
		) ?? UIImage()

		self.accessibilityText = accessibilityText
	}

	// MARK: - Internal

	let backgroundColor: UIColor = .enaColor(for: .cellBackground2)
	let borderColor: UIColor = .enaColor(for: .hairline)
	let qrCodeImage: UIImage
	let accessibilityText: String?

}
