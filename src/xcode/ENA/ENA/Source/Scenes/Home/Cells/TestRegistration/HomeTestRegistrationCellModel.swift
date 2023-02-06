//
// 🦠 Corona-Warn-App
//

import UIKit

class HomeTestRegistrationCellModel {

	// MARK: - Internal

	var title = AppStrings.Home.TestRegistration.title
	var subtitle = AppStrings.Home.TestRegistration.subtitle
	var description = AppStrings.Home.TestRegistration.description
	var buttonTitle = AppStrings.Home.TestRegistration.button
	var image = UIImage(named: "Illu_WarningAfterSelfTest")
	var tintColor: UIColor = .enaColor(for: .textPrimary1)
	var gradientViewType: GradientView.GradientType = .lightBlueToWhite
	var titleAccessibilityIdentifier = AccessibilityIdentifiers.Home.TestRegistrationCell.titleLabel
	var descriptionAccessibilityIdentifier = AccessibilityIdentifiers.Home.TestRegistrationCell.descriptionLabel
	var buttonAccessibilityIdentifier = AccessibilityIdentifiers.Home.TestRegistrationCell.submitCardButton

}
