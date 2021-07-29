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
		self.qrCodeImage = healthCertificate.qrCodeImage
		self.accessibilityText = accessibilityText
	}

	// MARK: - Internal

	let backgroundColor: UIColor = .enaColor(for: .cellBackground2)
	let borderColor: UIColor = .enaColor(for: .hairline)
	let qrCodeImage: UIImage?
	let accessibilityText: String?

}
