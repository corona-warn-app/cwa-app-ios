////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeHealthCertifiedPersonCellModel {

	// MARK: - Init

	init(
		healthCertifiedPerson: HealthCertifiedPerson
	) {
		title = AppStrings.HealthCertificate.Overview.VaccinationCertificate.title
		backgroundGradientType = healthCertifiedPerson.vaccinationState.gradientType
		name = healthCertifiedPerson.fullName

		switch healthCertifiedPerson.vaccinationState {
		case .partiallyVaccinated:
			backgroundImage = UIImage(named: "VaccinationCertificate_PartiallyVaccinated_Background")
			iconImage = UIImage(named: "VaccinationCertificate_PartiallyVaccinated_Icon")
			description = AppStrings.HealthCertificate.Overview.VaccinationCertificate.partiallyVaccinated
		case .fullyVaccinated(daysUntilCompleteProtection: let daysUntilCompleteProtection):
			backgroundImage = UIImage(named: "VaccinationCertificate_FullyVaccinated_Background")
			iconImage = UIImage(named: "VaccinationCertificate_FullyVaccinated_Icon")
			description = String(
				format: AppStrings.HealthCertificate.Overview.VaccinationCertificate.daysUntilCompleteProtection,
				daysUntilCompleteProtection
			)
		case .completelyProtected(let expirationDate):
			backgroundImage = UIImage(named: "VaccinationCertificate_CompletelyProtected_Background")
			iconImage = UIImage(named: "VaccinationCertificate_CompletelyProtected_Icon")
			description = String(
				format: AppStrings.HealthCertificate.Overview.VaccinationCertificate.vaccinationValidUntil,
				DateFormatter.localizedString(from: expirationDate, dateStyle: .medium, timeStyle: .none)
			)
		}
	}

	init(
		testCertificate: HealthCertificate
	) {
		title = AppStrings.HealthCertificate.Overview.TestCertificate.title
		backgroundGradientType = .green
		name = testCertificate.name.fullName
		backgroundImage = UIImage(named: "TestCertificate_Background")
		iconImage = UIImage(named: "TestCertificate_Icon")

		if let dateTimeOfSampleCollectionString = testCertificate.testEntry?.dateTimeOfSampleCollection,
		   let dateTimeOfSampleCollection = ISO8601DateFormatter.justLocalDateFormatter.date(from: dateTimeOfSampleCollectionString) {
			description = String(
				format: AppStrings.HealthCertificate.Overview.TestCertificate.testDate,
				DateFormatter.localizedString(from: dateTimeOfSampleCollection, dateStyle: .medium, timeStyle: .short)
			)
		} else {
			description = nil
		}
	}
	
	// MARK: - Internal

	var title: String
	var backgroundGradientType: GradientView.GradientType = .solidGrey
	var backgroundImage: UIImage?
	var iconImage: UIImage?
	var name: String?
	var description: String?

}
