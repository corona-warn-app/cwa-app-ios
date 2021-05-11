////
// 🦠 Corona-Warn-App
//

import UIKit

class VaccinationRegistrationCellModel {

	// MARK: - Internal

	var title = AppStrings.HealthCertificate.Info.RegisterCard.title
	var description = AppStrings.HealthCertificate.Info.RegisterCard.description
	var buttonTitle = AppStrings.HealthCertificate.Info.RegisterCard.buttonTitle
	var image = UIImage(named: "Vacc_Register")
	var tintColor: UIColor = .enaColor(for: .textPrimary1)
	var accessibilityIdentifier = AccessibilityIdentifiers.Home.registerVaccinationButton
}
