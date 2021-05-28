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
		backgroundGradientType = healthCertifiedPerson.vaccinationState == .completelyProtected ? .lightBlue : .solidGrey
		iconImage = healthCertifiedPerson.vaccinationState == .partiallyVaccinated ? UIImage(named: "Vacc_Incomplete") : UIImage(named: "Vaccination_full")
		name = healthCertifiedPerson.fullName

		switch healthCertifiedPerson.vaccinationState {
		case .partiallyVaccinated:
			vaccinationStateDescription = AppStrings.HealthCertificate.Overview.VaccinationCertificate.partiallyVaccinated
		case .fullyVaccinated(daysUntilCompleteProtection: let daysUntilCompleteProtection):
			vaccinationStateDescription = String(
				format: AppStrings.HealthCertificate.Overview.VaccinationCertificate.daysUntilCompleteProtection,
				daysUntilCompleteProtection
			)
		case .completelyProtected:
			vaccinationStateDescription = nil
		}

	}
	
	// MARK: - Internal

	var vaccinationStateDescription: String?
	var backgroundGradientType: GradientView.GradientType = .solidGrey
	var iconImage: UIImage?
	var name: String?

}
