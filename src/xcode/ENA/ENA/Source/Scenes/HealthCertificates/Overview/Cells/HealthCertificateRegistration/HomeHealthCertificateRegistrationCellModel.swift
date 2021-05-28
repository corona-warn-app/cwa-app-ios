////
// 🦠 Corona-Warn-App
//

import UIKit

class HomeHealthCertificateRegistrationCellModel {

	// MARK: - Internal

	let title = AppStrings.HealthCertificate.Overview.Registration.title
	let description = AppStrings.HealthCertificate.Overview.Registration.description
	let buttonTitle = AppStrings.HealthCertificate.Overview.Registration.buttonTitle
	let image = UIImage(named: "Vaccination_Register")
	let tintColor: UIColor = .enaColor(for: .textPrimary1)
	let accessibilityIdentifier = AccessibilityIdentifiers.Home.registerHealthCertificateButton

}
