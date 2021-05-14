////
// 🦠 Corona-Warn-App
//

import UIKit

struct HealthCertificateQRCodeCellViewModel {

	// MARK: - Init

	init(
		healthCertificate: HealthCertificateData
	) {
		var dateOfVaccination: String = ""
		if let vaccinationDate = healthCertificate.dateOfVaccination {
			dateOfVaccination = DateFormatter.localizedString(from: vaccinationDate, dateStyle: .medium, timeStyle: .none)
		}
		let expirationDate = DateFormatter.localizedString(from: healthCertificate.expirationDate, dateStyle: .medium, timeStyle: .none)
		self.validity = String(
			format: AppStrings.HealthCertificate.Details.validity,
			dateOfVaccination, expirationDate
		)
		self.certificate = String(
			format: AppStrings.HealthCertificate.Details.certificateCount,
			healthCertificate.doseNumber, healthCertificate.totalSeriesOfDoses
		)

		self.qrCodeImage = UIImage.qrCode(
			with: healthCertificate.base45,
			encoding: .utf8,
			size: CGSize(width: 280.0, height: 280.0),
			qrCodeErrorCorrectionLevel: .quartile
		) ?? UIImage()
	}

	// MARK: - Internal

	let backgroundColor: UIColor = .enaColor(for: .background)
	let borderColor: UIColor = .enaColor(for: .hairline)
	let certificate: String
	let validity: String
	let qrCodeImage: UIImage

}
