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
	@IBOutlet weak var titleLabel: ENALabel!
	@IBOutlet var textView1: UITextView!
	@IBOutlet var textView2: UITextView!
	@IBOutlet weak var textView3: UITextView!

	func configure(for riskDetectionState: RiskDetectionState) {
		if riskDetectionState == .disabled {
			titleLabel.text = AppStrings.ExposureNotificationSetting.descriptionTitleInactive
		} else {
			titleLabel.text = AppStrings.ExposureNotificationSetting.descriptionTitle
		}
		titleLabel.style = .title2
		textView1.text = AppStrings.ExposureNotificationSetting.descriptionText1
		textView1.font = UIFont.preferredFont(forTextStyle: .headline)
		textView2.text = AppStrings.ExposureNotificationSetting.descriptionText2
		textView3.text = AppStrings.ExposureNotificationSetting.descriptionText3
	}
}
