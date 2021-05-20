////
// 🦠 Corona-Warn-App
//

import UIKit

final class HealthCertificateCellViewModel {

	// MARK: - Init
	
	init(
		healthCertificate: HealthCertificate,
		gradientType: GradientView.GradientType
	) {
		self.healthCertificate = healthCertificate
		self.gradientType = gradientType
	}

	// MARK: - Internal

	let gradientType: GradientView.GradientType

	var headline: String? {
		guard
			let doseNumber = healthCertificate.vaccinationCertificates.first?.doseNumber,
			let totalSeriesOfDoses = healthCertificate.vaccinationCertificates.first?.totalSeriesOfDoses
		else {
			return nil
		}

		return String(
			format: AppStrings.HealthCertificate.Person.vaccinationCount,
			doseNumber,
			totalSeriesOfDoses
		)
	}

	var detail: String? {
		guard
			let dateOfVaccinationString = healthCertificate.vaccinationCertificates.first?.dateOfVaccination,
			let dateOfVaccinationDate = ISO8601DateFormatter.contactDiaryFormatter.date(from: dateOfVaccinationString)
		else {
			return nil
		}

		return String(
			format: AppStrings.HealthCertificate.Person.vaccinationDate,
			DateFormatter.localizedString(from: dateOfVaccinationDate, dateStyle: .medium, timeStyle: .none)
		)
	}

	var image: UIImage {
		if healthCertificate.isLastDoseInASeries {
			return UIImage(imageLiteralResourceName: "Icon - Vollschild")
		} else {
			return UIImage(imageLiteralResourceName: "Icon - Teilschild")
		}
	}

	// MARK: - Private

	private let healthCertificate: HealthCertificate

}
