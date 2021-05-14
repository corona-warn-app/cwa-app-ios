////
// 🦠 Corona-Warn-App
//

import UIKit

class HomeHealthCertificateRegistrationCellModel {

	// MARK: - Internal

	let title = AppStrings.HealthCertificate.Info.RegisterCard.title
	let description = AppStrings.HealthCertificate.Info.RegisterCard.description
	let buttonTitle = AppStrings.HealthCertificate.Info.RegisterCard.buttonTitle
	let image = UIImage(named: "Vaccination_Register")
	let tintColor: UIColor = .enaColor(for: .textPrimary1)
	let accessibilityIdentifier = AccessibilityIdentifiers.Home.registerVaccinationButton

}
