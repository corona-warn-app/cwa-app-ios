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
		backgroundGradientType = healthCertifiedPerson.vaccinationState.gradientType
		name = healthCertifiedPerson.fullName

		switch healthCertifiedPerson.vaccinationState {
		case .partiallyVaccinated:
			backgroundImage = UIImage(named: "VaccinationCertificate_PartiallyVaccinated_Background")
			iconImage = UIImage(named: "VaccinationCertificate_PartiallyVaccinated_Icon")
			vaccinationStateDescription = AppStrings.HealthCertificate.Overview.VaccinationCertificate.partiallyVaccinated
		case .fullyVaccinated(daysUntilCompleteProtection: let daysUntilCompleteProtection):
			backgroundImage = UIImage(named: "VaccinationCertificate_FullyVaccinated_Background")
			iconImage = UIImage(named: "VaccinationCertificate_FullyVaccinated_Icon")
			vaccinationStateDescription = String(
				format: AppStrings.HealthCertificate.Overview.VaccinationCertificate.daysUntilCompleteProtection,
				daysUntilCompleteProtection
			)
		case .completelyProtected(let expirationDate):
			backgroundImage = UIImage(named: "VaccinationCertificate_CompletelyProtected_Background")
			iconImage = UIImage(named: "VaccinationCertificate_CompletelyProtected_Icon")
			vaccinationStateDescription = String(
				format: AppStrings.HealthCertificate.Overview.VaccinationCertificate.vaccinationValidUntil,
				DateFormatter.localizedString(from: expirationDate, dateStyle: .medium, timeStyle: .none)
			)
		}

	}
	
	// MARK: - Internal

	var backgroundGradientType: GradientView.GradientType = .solidGrey
	var backgroundImage: UIImage?
	var iconImage: UIImage?
	var name: String?
	var vaccinationStateDescription: String?

}
