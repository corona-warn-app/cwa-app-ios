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

protocol ConfigurableENSettingCell: UITableViewCell {
	func configure(for state: RiskDetectionState)
}

class ImageTableViewCell: UITableViewCell, ConfigurableENSettingCell {
	@IBOutlet var imageContainerView: UIImageView!

	func configure(for state: RiskDetectionState) {
		let imageConfiguration = bannerImageConfig(for: state)
		imageContainerView.image = imageConfiguration.image
		if let label = imageConfiguration.label {
			imageContainerView.isAccessibilityElement = true
			imageContainerView.accessibilityLabel = label
		} else {
			imageContainerView.isAccessibilityElement = false
		}
	}

	private func bannerImageConfig(for state: RiskDetectionState) -> (image: UIImage?, label: String?) {
		switch state {
		case .enabled:
			return (UIImage(named: "Illu_Risikoermittlung_On"), AppStrings.ExposureNotificationSetting.accLabelEnabled)
		case .disabled:
			return (UIImage(named: "Illu_Risikoermittlung_Off"), AppStrings.ExposureNotificationSetting.accLabelDisabled)
		case .restricted:
			return (UIImage(named: "Illu_Risikoermittlung_Off"), AppStrings.ExposureNotificationSetting.accLabelDisabled)
		case .bluetoothOff:
			return (UIImage(named: "Illu_Bluetooth_Off"), AppStrings.ExposureNotificationSetting.accLabelBluetoothOff)
		case .internetOff:
			return (UIImage(named: "Illu_Internet_Off"), AppStrings.ExposureNotificationSetting.accLabelInternetOff)
		}
	}
}
