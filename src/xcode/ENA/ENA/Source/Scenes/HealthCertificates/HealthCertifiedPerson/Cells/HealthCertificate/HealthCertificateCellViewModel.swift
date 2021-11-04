//
// 🦠 Corona-Warn-App
//

import UIKit

final class HealthCertificateCellViewModel {

	// MARK: - Init
	
	init(
		healthCertificate: HealthCertificate,
		healthCertifiedPerson: HealthCertifiedPerson
	) {
		self.healthCertificate = healthCertificate
		self.healthCertifiedPerson = healthCertifiedPerson
	}

	// MARK: - Internal
	
	let healthCertificate: HealthCertificate

	lazy var gradientType: GradientView.GradientType = {
		if healthCertificate.validityState == .invalid || healthCertificate.validityState == .blocked || (healthCertificate.type != .test && healthCertificate.validityState == .expired) ||
			healthCertificate != healthCertifiedPerson.mostRelevantHealthCertificate {
			return .solidGrey(withStars: false)
		} else {
			return .lightBlue(withStars: false)
		}
	}()

	lazy var headline: String? = {
		switch healthCertificate.type {
		case .vaccination:
			return AppStrings.HealthCertificate.Person.VaccinationCertificate.headline
		case .test:
			return AppStrings.HealthCertificate.Person.TestCertificate.headline
		case .recovery:
			return AppStrings.HealthCertificate.Person.RecoveryCertificate.headline
		}
	}()

	lazy var subheadline: String? = {
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
	}()

	lazy var detail: String? = {
		switch healthCertificate.entry {
		case .vaccination(let vaccinationEntry):
			return vaccinationEntry.localVaccinationDate.map {
				String(
					format: AppStrings.HealthCertificate.Person.VaccinationCertificate.vaccinationDate,
					DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
				)
			}
		case .test(let testEntry):
			return testEntry.sampleCollectionDate.map {
				String(
					format: AppStrings.HealthCertificate.Person.TestCertificate.sampleCollectionDate,
					DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
				)
			}
		case .recovery(let recoveryEntry):
			return recoveryEntry.localCertificateValidityEndDate.map {
				String(
					format: AppStrings.HealthCertificate.Person.RecoveryCertificate.validityDate,
					DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
				)
			}
		}
	}()

	lazy var validityStateInfo: String? = {
		if healthCertificate.validityState == .invalid || healthCertificate.validityState == .blocked || (healthCertificate.type != .test && healthCertificate.validityState != .valid) {
			switch healthCertificate.validityState {
			case .valid:
				return nil
			case .expiringSoon:
				return String(
					format: AppStrings.HealthCertificate.ValidityState.expiringSoon,
					DateFormatter.localizedString(from: healthCertificate.expirationDate, dateStyle: .short, timeStyle: .none),
					DateFormatter.localizedString(from: healthCertificate.expirationDate, dateStyle: .none, timeStyle: .short)
				)
			case .expired:
				return AppStrings.HealthCertificate.ValidityState.expired
			case .invalid:
				return AppStrings.HealthCertificate.ValidityState.invalid
			case .blocked:
				return AppStrings.HealthCertificate.ValidityState.blocked
			}
		} else if healthCertificate.isNew {
			return AppStrings.HealthCertificate.Person.newlyAddedCertificate
		} else {
			return nil
		}
	}()

	lazy var image: UIImage = {
		if healthCertificate.validityState == .invalid || healthCertificate.validityState == .blocked || (healthCertificate.type != .test && healthCertificate.validityState == .expired) {
			return UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small")
		}

		switch healthCertificate.entry {
		case .vaccination(let vaccinationEntry) where vaccinationEntry.isLastDoseInASeries:
			if case .completelyProtected = healthCertifiedPerson.vaccinationState {
				return UIImage(imageLiteralResourceName: "VaccinationCertificate_CompletelyProtected_Icon")
			} else {
				return UIImage(imageLiteralResourceName: "VaccinationCertificate_FullyVaccinated_Icon")
			}
		case .vaccination:
			return UIImage(imageLiteralResourceName: "VaccinationCertificate_PartiallyVaccinated_Icon")
		case .test:
			return UIImage(imageLiteralResourceName: "TestCertificate_Icon")
		case .recovery:
			return UIImage(imageLiteralResourceName: "RecoveryCertificate_Icon")
		}
	}()

	lazy var isCurrentlyUsedCertificateHintVisible: Bool = {
		healthCertificate == healthCertifiedPerson.mostRelevantHealthCertificate
	}()

	lazy var isUnseenNewsIndicatorVisible: Bool = {
		healthCertificate.isNew || healthCertificate.isValidityStateNew
	}()

	// MARK: - Private

	private let healthCertifiedPerson: HealthCertifiedPerson

}
