////
// 🦠 Corona-Warn-App
//

import UIKit
import HealthCertificateToolkit

struct HealthCertificateQRCodeViewModel {

	// MARK: - Init

	init(
		healthCertificate: HealthCertificate,
		accessibilityLabel: String,
		showInfoHit: @escaping () -> Void
	) {
		self.base45 = healthCertificate.base45
		self.shouldBlockCertificateCode = healthCertificate.validityState == .invalid || healthCertificate.validityState == .blocked || (healthCertificate.type != .test && healthCertificate.validityState == .expired)
		self.accessibilityLabel = accessibilityLabel
		self.showInfo = showInfoHit
	}

	init(
		base45: Base45,
		shouldBlockCertificateCode: Bool,
		accessibilityLabel: String,
		showInfoHit: @escaping () -> Void
	) {
		self.base45 = base45
		self.shouldBlockCertificateCode = shouldBlockCertificateCode
		self.accessibilityLabel = accessibilityLabel
		self.showInfo = showInfoHit
	}

	// MARK: - Internal

	let shouldBlockCertificateCode: Bool
	let accessibilityLabel: String
	let showInfo: () -> Void

	var qrCodeImage: UIImage? {
		var qrCodeString: String
		if shouldBlockCertificateCode {
			qrCodeString = AppStrings.Links.invalidSignatureFAQ
		} else {
			qrCodeString = base45
		}

		let qrCodeSize = UIScreen.main.bounds.width - 100

		return UIImage.qrCode(
			with: qrCodeString,
			encoding: .utf8,
			size: CGSize(width: qrCodeSize, height: qrCodeSize),
			scale: UIScreen.main.scale,
			qrCodeErrorCorrectionLevel: .medium
		)
	}

	// MARK: - Private

	private let base45: Base45

}
