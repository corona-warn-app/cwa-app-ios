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
	func configure(for state: ENStateHandler.State)
}

class ImageTableViewCell: UITableViewCell, ConfigurableENSettingCell {
	@IBOutlet var imageContainerView: UIImageView!

	private struct BannerImageConfig {
		init(
			_ image: UIImage?,
			_ label: String?,
			_ accessibilityIdentifier: String?
		) {
			self.image = image
			self.label = label
			self.accessibilityIdentifier = accessibilityIdentifier
		}
		let image: UIImage?
		let label: String?
		let accessibilityIdentifier: String?
	}

	func configure(for state: ENStateHandler.State) {
		let imageConfiguration = bannerImageConfig(for: state)
		imageContainerView.image = imageConfiguration.image
		if imageConfiguration.label != nil {
			imageContainerView.isAccessibilityElement = true
		} else {
			imageContainerView.isAccessibilityElement = false
		}
		imageContainerView.accessibilityLabel = imageConfiguration.label
		imageContainerView.accessibilityIdentifier = imageConfiguration.accessibilityIdentifier
	}

	private func bannerImageConfig(for state: ENStateHandler.State) -> BannerImageConfig {
		switch state {
		case .enabled:
			return .init(
				UIImage(named: "Illu_Risikoermittlung_On"),
				AppStrings.ExposureNotificationSetting.accLabelEnabled,
				"AppStrings.ExposureNotificationSetting.accLabelEnabled"
			)
		case .disabled, .restricted, .notAuthorized, .unknown:
			return .init(
				UIImage(named: "Illu_Risikoermittlung_Off"),
				AppStrings.ExposureNotificationSetting.accLabelDisabled,
				"AppStrings.ExposureNotificationSetting.accLabelDisabled"
			)
		case .bluetoothOff:
			return .init(
				UIImage(named: "Illu_Bluetooth_Off"),
				AppStrings.ExposureNotificationSetting.accLabelBluetoothOff,
				"AppStrings.ExposureNotificationSetting.accLabelBluetoothOff"
			)
		}
	}
}
