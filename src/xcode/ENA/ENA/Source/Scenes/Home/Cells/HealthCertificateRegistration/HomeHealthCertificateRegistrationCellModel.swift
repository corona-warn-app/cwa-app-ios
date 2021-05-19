////
// 🦠 Corona-Warn-App
//

import UIKit

class HomeHealthCertificateRegistrationCellModel {

	// MARK: - Internal

	let title = AppStrings.HealthCertificate.Home.Registration.title
	let description = AppStrings.HealthCertificate.Home.Registration.description
	let buttonTitle = AppStrings.HealthCertificate.Home.Registration.buttonTitle
	let image = UIImage(named: "Vaccination_Register")
	let tintColor: UIColor = .enaColor(for: .textPrimary1)
	let accessibilityIdentifier = AccessibilityIdentifiers.Home.registerHealthCertificateButton

}
