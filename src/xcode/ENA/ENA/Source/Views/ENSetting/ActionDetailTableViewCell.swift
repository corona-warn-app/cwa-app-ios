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

class ActionDetailTableViewCell: UITableViewCell, ConfigurableENSettingCell {
	@IBOutlet var iconImageView1: UIImageView!
	@IBOutlet var iconImageView2: UIImageView!
	@IBOutlet var actionTitleLabel: UILabel!
	@IBOutlet var descriptionTextView: UITextView!
	@IBOutlet var actionButton: ENAButton!

	@IBAction func actionButtonTapped(_: Any) {
		guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
			return
		}

		if UIApplication.shared.canOpenURL(settingsUrl) {
			UIApplication.shared.open(settingsUrl, completionHandler: nil)
		}
	}

	override func awakeFromNib() {
		actionButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body).scaledFont(size: 17, weight: .semibold)
		actionButton.titleLabel?.adjustsFontForContentSizeCategory = true
		actionButton.titleLabel?.lineBreakMode = .byWordWrapping
		actionButton.layer.masksToBounds = true
		actionButton.contentEdgeInsets = .init(top: 14.0, left: 8.0, bottom: 14.0, right: 8.0)
	}

	func configure(for state: RiskDetectionState) {
		iconImageView1.image = images(for: state).0
		iconImageView2.image = images(for: state).1
		actionButton.setTitle(AppStrings.ExposureNotificationSetting.detailActionButtonTitle, for: .normal)

		switch state {
		case .enabled, .disabled:
			return
		case .bluetoothOff:
			actionTitleLabel.text = AppStrings.ExposureNotificationSetting.activateBluetooth
			descriptionTextView.text = AppStrings.ExposureNotificationSetting.bluetoothDescription
			iconImageView2.isHidden = true
		case .internetOff:
			actionTitleLabel.text = AppStrings.ExposureNotificationSetting.activateInternet
			descriptionTextView.text = AppStrings.ExposureNotificationSetting.internetDescription
			iconImageView2.isHidden = false
		case .restricted:
			actionTitleLabel.text = AppStrings.ExposureNotificationSetting.activateOSENSetting
			descriptionTextView.text = AppStrings.ExposureNotificationSetting.activateOSENSettingDescription
			iconImageView2.isHidden = true
		}
	}

	private func images(for state: RiskDetectionState) -> (UIImage?, UIImage?) {
		switch state {
		case .enabled, .disabled:
			return (nil, nil)
		case .bluetoothOff:
			return (UIImage(named: "Icons_Bluetooth"), nil)
		case .internetOff:
			return (UIImage(named: "Icons_MobileDaten"), UIImage(named: "Icons_iOS_Wifi"))
		case .restricted:
			return (UIImage(named: "Icons_iOS_Settings"), nil)
		}
	}
}
