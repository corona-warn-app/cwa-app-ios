////
// 🦠 Corona-Warn-App
//

import UIKit

struct HealthCertificateQRCodeViewModel {

	// MARK: - Init

	init(
		healthCertificate: HealthCertificate,
		accessibilityLabel: String
	) {
		self.healthCertificate = healthCertificate
		self.accessibilityLabel = accessibilityLabel
	}

	// MARK: - Internal

	let accessibilityLabel: String

	var qrCodeImage: UIImage? {
		var qrCodeString: String
		if shouldBlockCertificateCode {
			qrCodeString = AppStrings.Links.invalidSignatureFAQ
		} else {
			qrCodeString = healthCertificate.base45
		}

		let qrCodeSize = UIScreen.main.bounds.width - 100

		return UIImage.qrCode(
			with: qrCodeString,
			encoding: .utf8,
			size: CGSize(width: qrCodeSize, height: qrCodeSize),
			qrCodeErrorCorrectionLevel: .medium
		)
	}

	var shouldBlockCertificateCode: Bool {
		return healthCertificate.validityState == .invalid ||
			(healthCertificate.type != .test && healthCertificate.validityState == .expired)
	}

	// MARK: - Private

	private let healthCertificate: HealthCertificate

}
