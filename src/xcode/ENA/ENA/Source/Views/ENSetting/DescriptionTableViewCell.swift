// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import Foundation
import UIKit

class DescriptionTableViewCell: UITableViewCell, ConfigurableENSettingCell {
	@IBOutlet var titleLabel: ENALabel!
	@IBOutlet var label1: UILabel!
	@IBOutlet var label2: UILabel!
	@IBOutlet var label3: UILabel!

	func configure(for riskDetectionState: ENStateHandler.State) {
		if riskDetectionState == .disabled {
			titleLabel.text = AppStrings.ExposureNotificationSetting.descriptionTitleInactive
		} else {
			titleLabel.text = AppStrings.ExposureNotificationSetting.descriptionTitle
		}
		label1.text = AppStrings.ExposureNotificationSetting.descriptionText1
		label2.text = AppStrings.ExposureNotificationSetting.descriptionText2
		label3.text = AppStrings.ExposureNotificationSetting.descriptionText3

		titleLabel.isAccessibilityElement = true
		label1.isAccessibilityElement = true
		label2.isAccessibilityElement = true
		label3.isAccessibilityElement = true

		titleLabel.accessibilityIdentifier = (riskDetectionState == .disabled) ?
			AccessibilityIdentifiers.ExposureNotificationSetting.descriptionTitleInactive : AccessibilityIdentifiers.ExposureNotificationSetting.descriptionTitle
		label1.accessibilityIdentifier = AccessibilityIdentifiers.ExposureNotificationSetting.descriptionText1
		label2.accessibilityIdentifier = AccessibilityIdentifiers.ExposureNotificationSetting.descriptionText2
		label3.accessibilityIdentifier = AccessibilityIdentifiers.ExposureNotificationSetting.descriptionText3

		titleLabel.accessibilityTraits = .header
		label1.accessibilityTraits = .staticText
		label2.accessibilityTraits = .staticText
		label3.accessibilityTraits = .staticText
	}
}
