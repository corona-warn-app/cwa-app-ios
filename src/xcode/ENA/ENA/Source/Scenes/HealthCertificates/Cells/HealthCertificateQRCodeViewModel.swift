////
// 🦠 Corona-Warn-App
//

import UIKit
import HealthCertificateToolkit

struct HealthCertificateQRCodeViewModel {

	// MARK: - Init

	init(
		healthCertificate: HealthCertificate,
		showRealQRCodeIfValidityStateBlocked: Bool,
		accessibilityLabel: String,
		covPassCheckInfoPosition: CovPassCheckInfoPosition,
		onCovPassCheckInfoButtonTap: @escaping () -> Void
	) {
		self.base45 = healthCertificate.base45
		self.shouldBlockCertificateCode = !healthCertificate.isUsable && !(showRealQRCodeIfValidityStateBlocked && healthCertificate.validityState == .blocked)
		self.accessibilityLabel = accessibilityLabel
		self.covPassCheckInfoPosition = covPassCheckInfoPosition
		self.onCovPassCheckInfoButtonTap = onCovPassCheckInfoButtonTap
	}

	init(
		base45: Base45,
		shouldBlockCertificateCode: Bool,
		accessibilityLabel: String,
		covPassCheckInfoPosition: CovPassCheckInfoPosition,
		onCovPassCheckInfoButtonTap: @escaping () -> Void
	) {
		self.base45 = base45
		self.shouldBlockCertificateCode = shouldBlockCertificateCode
		self.accessibilityLabel = accessibilityLabel
		self.covPassCheckInfoPosition = covPassCheckInfoPosition
		self.onCovPassCheckInfoButtonTap = onCovPassCheckInfoButtonTap
	}

	// MARK: - Internal

	enum CovPassCheckInfoPosition {
		case top
		case bottom
	}

	let shouldBlockCertificateCode: Bool
	let accessibilityLabel: String
	let covPassCheckInfoPosition: CovPassCheckInfoPosition
	let onCovPassCheckInfoButtonTap: () -> Void

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
