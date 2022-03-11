//
// 🦠 Corona-Warn-App
//

import UIKit

final class HealthCertificateCellViewModel {

	// MARK: - Init
	
	init(
		healthCertificate: HealthCertificate,
		healthCertifiedPerson: HealthCertifiedPerson,
		details: HealthCertificateCellDetails = .allDetails
	) {
		self.healthCertificate = healthCertificate
		self.healthCertifiedPerson = healthCertifiedPerson
		self.details = details
	}

	// MARK: - Internal
	
	enum HealthCertificateCellDetails {
		case allDetails
		case overview
		case overviewPlusName
	}
	
	let healthCertificate: HealthCertificate
	
	lazy var gradientType: GradientView.GradientType = {
		switch details {
		case .allDetails:
			if healthCertificate.isUsable &&
				healthCertificate == healthCertifiedPerson.mostRelevantHealthCertificate {
				return healthCertifiedPerson.gradientType
			} else {
				return .solidGrey
			}
		case .overview, .overviewPlusName:
			return .lightBlue
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

	lazy var name: String? = {
		switch details {
		case .allDetails, .overview:
			return nil
		case .overviewPlusName:
			return healthCertifiedPerson.name?.fullName
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
			return recoveryEntry.localDateOfFirstPositiveNAAResult.map {
				String(
					format: AppStrings.HealthCertificate.Person.RecoveryCertificate.positiveTestFrom,
					DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
				)
			}
		}
	}()

	lazy var validityStateInfo: String? = {
		switch details {
		case .allDetails:
			if !healthCertificate.isConsideredValid {
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
		case .overview, .overviewPlusName:
			return nil
		}
	}()

	lazy var image: UIImage = {
		guard healthCertificate.isUsable else {
			return UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small")
		}

		switch healthCertificate.entry {
		case .vaccination(let vaccinationEntry) where vaccinationEntry.isLastDoseInASeriesOrBooster:
			return UIImage(imageLiteralResourceName: "VaccinationCertificate_CompletelyProtected_Icon")
		case .vaccination:
			return UIImage(imageLiteralResourceName: "VaccinationCertificate_PartiallyVaccinated_Icon")
		case .test:
			return UIImage(imageLiteralResourceName: "TestCertificate_Icon")
		case .recovery:
			return UIImage(imageLiteralResourceName: "RecoveryCertificate_Icon")
		}
	}()

	lazy var isCurrentlyUsedCertificateHintVisible: Bool = {
		switch details {
		case .allDetails:
			return healthCertificate == healthCertifiedPerson.mostRelevantHealthCertificate
		case .overview, .overviewPlusName:
			return false
		}
	}()

	lazy var currentlyUsedImage: UIImage? = {
		switch gradientType {
		case .lightBlue:
			return UIImage(named: "Icon_CurrentlyUsedCertificate_light")
		case .mediumBlue:
			return UIImage(named: "Icon_CurrentlyUsedCertificate_medium")
		case .darkBlue:
			return UIImage(named: "Icon_CurrentlyUsedCertificate_dark")
		case .blueRedTilted, .blueOnly, .solidGrey, .whiteToLightBlue:
			return UIImage(named: "Icon_CurrentlyUsedCertificate_grey")
		}
	}()

	lazy var isUnseenNewsIndicatorVisible: Bool = {
		switch details {
		case .allDetails:
			return healthCertificate.isNew || healthCertificate.isValidityStateNew
		case .overview, .overviewPlusName:
			return false
		}
	}()

	// MARK: - Private

	private let healthCertifiedPerson: HealthCertifiedPerson
	private let details: HealthCertificateCellDetails
}
