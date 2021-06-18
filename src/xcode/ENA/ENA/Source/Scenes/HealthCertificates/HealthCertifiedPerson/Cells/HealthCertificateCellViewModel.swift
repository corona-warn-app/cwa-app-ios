////
// 🦠 Corona-Warn-App
//

import UIKit

final class HealthCertificateCellViewModel {

	// MARK: - Init
	
	init(
		healthCertificate: HealthCertificate,
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificateService: HealthCertificateService
	) {
		self.healthCertificate = healthCertificate
		self.healthCertifiedPerson = healthCertifiedPerson
		self.healthCertificateService = healthCertificateService
	}

	// MARK: - Internal

	var gradientType: GradientView.GradientType {
		if healthCertificate == healthCertifiedPerson.mostRelevantHealthCertificate {
			return .lightBlue
		} else {
			return .solidGrey
		}
	}

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
				if case .completelyProtected = healthCertifiedPerson.vaccinationState {
					return UIImage(imageLiteralResourceName: "VaccinationCertificate_CompletelyProtected_Icon")
				} else {
					return UIImage(imageLiteralResourceName: "VaccinationCertificate_FullyVaccinated_Icon")
				}
			} else {
				return UIImage(imageLiteralResourceName: "VaccinationCertificate_PartiallyVaccinated_Icon")
			}
		case .test:
			return UIImage(imageLiteralResourceName: "TestCertificate_Icon")
		case .recovery:
			return UIImage(imageLiteralResourceName: "RecoveryCertificate_Icon")
		}
	}

	// MARK: - Private

	private let healthCertificate: HealthCertificate
	private let healthCertifiedPerson: HealthCertifiedPerson
	private let healthCertificateService: HealthCertificateService

}
