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
			let doseNumber = healthCertificate.vaccinationEntry?.doseNumber,
			let totalSeriesOfDoses = healthCertificate.vaccinationEntry?.totalSeriesOfDoses
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
		guard let localVaccinationDate = healthCertificate.vaccinationEntry?.localVaccinationDate else {
			return nil
		}

		return String(
			format: AppStrings.HealthCertificate.Person.vaccinationDate,
			DateFormatter.localizedString(from: localVaccinationDate, dateStyle: .medium, timeStyle: .none)
		)
	}

	var image: UIImage {
		if healthCertificate.vaccinationEntry?.isLastDoseInASeries ?? false {
			return UIImage(imageLiteralResourceName: "Icon - Vollschild")
		} else {
			return UIImage(imageLiteralResourceName: "Icon - Teilschild")
		}
	}

	// MARK: - Private

	private let healthCertificate: HealthCertificate

}
