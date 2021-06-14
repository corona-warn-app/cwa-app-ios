////
// 🦠 Corona-Warn-App
//

import UIKit

struct HealthCertificateQRCodeCellViewModel {

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

		switch healthCertificate.type {
		case .vaccination(let vaccinationEntry):
			var dateOfVaccination: String = ""
			if let localVaccinationDate = vaccinationEntry.localVaccinationDate {
				dateOfVaccination = DateFormatter.localizedString(from: localVaccinationDate, dateStyle: .medium, timeStyle: .none)
			}
			let expirationDate = DateFormatter.localizedString(from: healthCertificate.expirationDate, dateStyle: .medium, timeStyle: .none)
			self.validity = String(
				format: AppStrings.HealthCertificate.Details.validity,
				dateOfVaccination, expirationDate
			)
			self.certificate = String(
				format: AppStrings.HealthCertificate.Details.certificateCount,
				vaccinationEntry.doseNumber, vaccinationEntry.totalSeriesOfDoses
			)
		case .test, .recovery:
			self.validity = nil
			self.certificate = nil
		}
	}

	// MARK: - Internal

	let backgroundColor: UIColor = .enaColor(for: .cellBackground2)
	let borderColor: UIColor = .enaColor(for: .hairline)
	let certificate: String?
	let validity: String?
	let qrCodeImage: UIImage
	let accessibilityText: String?
}
