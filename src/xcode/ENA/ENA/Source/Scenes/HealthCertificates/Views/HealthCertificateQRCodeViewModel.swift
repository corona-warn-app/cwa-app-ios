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
		imageAccessibilityTraits: UIAccessibilityTraits,
		accessibilityLabel: String,
		qrCodeAccessibilityID: String,
		covPassCheckInfoPosition: CovPassCheckInfoPosition,
		onCovPassCheckInfoButtonTap: @escaping () -> Void
	) {
		self.shouldBlockCertificateCode = !healthCertificate.isUsable && !(showRealQRCodeIfValidityStateBlocked && healthCertificate.validityState == .blocked)
		self.imageAccessibilityTraits = imageAccessibilityTraits
		self.accessibilityLabel = accessibilityLabel
		self.qrCodeAccessibilityID = qrCodeAccessibilityID
		self.covPassCheckInfoPosition = covPassCheckInfoPosition
		self.onCovPassCheckInfoButtonTap = onCovPassCheckInfoButtonTap

		updateImage(with: healthCertificate)
	}

	init(
		base45: Base45,
		shouldBlockCertificateCode: Bool,
		imageAccessibilityTraits: UIAccessibilityTraits,
		accessibilityLabel: String,
		qrCodeAccessibilityID: String,
		covPassCheckInfoPosition: CovPassCheckInfoPosition,
		onCovPassCheckInfoButtonTap: @escaping () -> Void
	) {
		self.shouldBlockCertificateCode = shouldBlockCertificateCode
		self.imageAccessibilityTraits = imageAccessibilityTraits
		self.accessibilityLabel = accessibilityLabel
		self.qrCodeAccessibilityID = qrCodeAccessibilityID
		self.covPassCheckInfoPosition = covPassCheckInfoPosition
		self.onCovPassCheckInfoButtonTap = onCovPassCheckInfoButtonTap

		updateImage(with: base45)
	}

	// MARK: - Internal

	enum CovPassCheckInfoPosition {
		case top
		case bottom
	}

	let shouldBlockCertificateCode: Bool
	let imageAccessibilityTraits: UIAccessibilityTraits
	let accessibilityLabel: String
	let qrCodeAccessibilityID: String
	let covPassCheckInfoPosition: CovPassCheckInfoPosition
	let onCovPassCheckInfoButtonTap: () -> Void

	@DidSetPublished var qrCodeImage: UIImage?

	func updateImage(with healthCertificate: HealthCertificate) {
		updateImage(with: healthCertificate.base45)
	}

	// MARK: - Private

	private func updateImage(with base45: Base45) {
		var qrCodeString: String
		if shouldBlockCertificateCode {
			qrCodeString = AppStrings.Links.invalidSignatureFAQ
		} else {
			qrCodeString = base45
		}

		let qrCodeSize = UIScreen.main.bounds.width - 100

		qrCodeImage = UIImage.qrCode(
			with: qrCodeString,
			encoding: .utf8,
			size: CGSize(width: qrCodeSize, height: qrCodeSize),
			scale: UIScreen.main.scale,
			qrCodeErrorCorrectionLevel: .medium
		)
	}

}
