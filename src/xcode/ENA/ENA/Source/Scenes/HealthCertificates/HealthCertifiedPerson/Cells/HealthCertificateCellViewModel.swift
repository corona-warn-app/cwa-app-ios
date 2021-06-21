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
		switch healthCertificate.entry {
		case .vaccination(let vaccinationEntry):
			return String(
				format: AppStrings.HealthCertificate.Person.vaccinationCount,
				vaccinationEntry.doseNumber,
				vaccinationEntry.totalSeriesOfDoses
			)
		case .test:
			return nil
		case .recovery:
			return nil
		}
	}

	var detail: String? {
		switch healthCertificate.entry {
		case .vaccination(let vaccinationEntry):
			return vaccinationEntry.localVaccinationDate.map {
				String(
					format: AppStrings.HealthCertificate.Person.vaccinationDate,
					DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none)
				)
			}
		case .test:
			return nil
		case .recovery:
			return nil
		}
	}

	var image: UIImage {
		switch healthCertificate.entry {
		case .vaccination(let vaccinationEntry):
			if vaccinationEntry.isLastDoseInASeries {
				return UIImage(imageLiteralResourceName: "Icon - Vollschild")
			} else {
				return UIImage(imageLiteralResourceName: "Icon - Teilschild")
			}
		case .test:
			return UIImage()
		case .recovery:
			return UIImage()
		}
	}

	// MARK: - Private

	private let healthCertificate: HealthCertificate

}
