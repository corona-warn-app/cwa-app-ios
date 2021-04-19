//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class HomeTestRegistrationCellModel {

	// MARK: - Internal

	var title = AppStrings.Home.TestRegistration.title
	var description = AppStrings.Home.TestRegistration.description
	var buttonTitle = AppStrings.Home.TestRegistration.button
	var image = UIImage(named: "Illu_Hand_with_phone-initial")
	var tintColor: UIColor = .enaColor(for: .textPrimary1)
	var accessibilityIdentifier = AccessibilityIdentifiers.Home.submitCardButton

}
