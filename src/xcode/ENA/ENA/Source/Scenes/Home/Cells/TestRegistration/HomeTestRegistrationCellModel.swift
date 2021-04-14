//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class HomeTestRegistrationCellModel {

	// MARK: - Internal

	var title = AppStrings.Home.submitCardTitle
	var description = AppStrings.Home.submitCardBody
	var buttonTitle = AppStrings.Home.submitCardButton
	var image = UIImage(named: "Illu_Hand_with_phone-initial")
	var tintColor: UIColor = .enaColor(for: .textPrimary1)
	var accessibilityIdentifier = AccessibilityIdentifiers.Home.submitCardButton

}
