//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DescriptionTableViewCell: UITableViewCell, ConfigurableENSettingCell {
	@IBOutlet var titleLabel: ENALabel!
	@IBOutlet var label1: UILabel!
	@IBOutlet var label2: UILabel!
	@IBOutlet var label3: UILabel!
	@IBOutlet var label4: UILabel!

	func configure(for riskDetectionState: ENStateHandler.State) {
		if riskDetectionState == .disabled {
			titleLabel.text = AppStrings.ExposureNotificationSetting.descriptionTitleInactive
		} else {
			titleLabel.text = AppStrings.ExposureNotificationSetting.descriptionTitle
		}
		label1.text = AppStrings.ExposureNotificationSetting.descriptionText1
		label2.text = AppStrings.ExposureNotificationSetting.descriptionText2
		label3.text = AppStrings.ExposureNotificationSetting.descriptionText3
		label4.text = AppStrings.ExposureNotificationSetting.descriptionText4

		titleLabel.isAccessibilityElement = true
		label1.isAccessibilityElement = true
		label2.isAccessibilityElement = true
		label3.isAccessibilityElement = true
		label4.isAccessibilityElement = true

		titleLabel.accessibilityIdentifier = (riskDetectionState == .disabled) ?
			AccessibilityIdentifiers.ExposureNotificationSetting.descriptionTitleInactive : AccessibilityIdentifiers.ExposureNotificationSetting.descriptionTitle
		label1.accessibilityIdentifier = AccessibilityIdentifiers.ExposureNotificationSetting.descriptionText1
		label2.accessibilityIdentifier = AccessibilityIdentifiers.ExposureNotificationSetting.descriptionText2
		label3.accessibilityIdentifier = AccessibilityIdentifiers.ExposureNotificationSetting.descriptionText3
		label4.accessibilityIdentifier = AccessibilityIdentifiers.ExposureNotificationSetting.descriptionText4

		titleLabel.accessibilityTraits = .header
		label1.accessibilityTraits = .staticText
		label2.accessibilityTraits = .staticText
		label3.accessibilityTraits = .staticText
		label4.accessibilityTraits = .staticText
	}
}
