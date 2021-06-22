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
		switch healthCertificate.type {
		case .vaccination:
			return AppStrings.HealthCertificate.Person.VaccinationCertificate.headline
		case .test:
			return AppStrings.HealthCertificate.Person.TestCertificate.headline
		case .recovery:
			return AppStrings.HealthCertificate.Person.RecoveryCertificate.headline
		}
	}

	var subheadline: String? {
		switch healthCertificate.entry {
		case .vaccination(let vaccinationEntry):
			return String(
				format: AppStrings.HealthCertificate.Person.VaccinationCertificate.vaccinationCount,
				vaccinationEntry.doseNumber,
				vaccinationEntry.totalSeriesOfDoses
			)
		case .test(let testEntry) where testEntry.coronaTestType == .pcr:
			return AppStrings.HealthCertificate.Person.TestCertificate.pcrTest
		case .test(let testEntry) where testEntry.coronaTestType == .antigen:
			return AppStrings.HealthCertificate.Person.TestCertificate.antigenTest
		case .test:
			// In case the test type could not be determined
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
					format: AppStrings.HealthCertificate.Person.VaccinationCertificate.vaccinationDate,
					DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none)
				)
			}
		case .test(let testEntry):
			return testEntry.sampleCollectionDate.map {
				String(
					format: AppStrings.HealthCertificate.Person.TestCertificate.sampleCollectionDate,
					DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none)
				)
			}
		case .recovery(let recoveryEntry):
			return recoveryEntry.localCertificateValidityEndDate.map {
				String(
					format: AppStrings.HealthCertificate.Person.RecoveryCertificate.validityDate,
					DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none)
				)
			}
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

	var isCurrentlyUsedCertificateHintVisible: Bool {
		healthCertificate == healthCertifiedPerson.mostRelevantHealthCertificate
	}

	// MARK: - Private

	private let healthCertificate: HealthCertificate
	private let healthCertifiedPerson: HealthCertifiedPerson
	private let healthCertificateService: HealthCertificateService

}
