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

class ActionDetailTableViewCell: UITableViewCell, ActionCell {

	@IBOutlet var iconImageView1: UIImageView!
	@IBOutlet var iconImageView2: UIImageView!
	@IBOutlet weak var actionTitleLabel: ENALabel!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var actionButton: ENAButton!

	weak var delegate: ActionTableViewCellDelegate?
	var state: ENStateHandler.State?

	@IBAction func actionButtonTapped(_: Any) {
		if let state = self.state, state == .unknown {
			delegate?.performAction(action: .askConsent)
		} else {
			if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
				UIApplication.shared.canOpenURL(settingsUrl) {
				UIApplication.shared.open(settingsUrl, completionHandler: nil)
			}
		}
	}

	func configure(for state: ENStateHandler.State) {
		iconImageView1.image = images(for: state).0
		iconImageView2.image = images(for: state).1
		actionButton.setTitle(AppStrings.ExposureNotificationSetting.detailActionButtonTitle, for: .normal)

		switch state {
		case .enabled, .disabled:
			return
		case .bluetoothOff:
			actionTitleLabel.text = AppStrings.ExposureNotificationSetting.activateBluetooth
			descriptionLabel.text = AppStrings.ExposureNotificationSetting.bluetoothDescription
			iconImageView2.isHidden = true
		case .restricted:
			actionTitleLabel.text = AppStrings.ExposureNotificationSetting.activateParentalControlENSetting
			descriptionLabel.text = AppStrings.ExposureNotificationSetting.activateParentalControlENSettingDescription
			iconImageView2.isHidden = true
		case .notAuthorized:
			actionTitleLabel.text = AppStrings.ExposureNotificationSetting.activateOSENSetting
			descriptionLabel.text = AppStrings.ExposureNotificationSetting.activateOSENSettingDescription
			iconImageView2.isHidden = true
		case .unknown:
			actionTitleLabel.text = AppStrings.ExposureNotificationSetting.authorizationRequiredENSetting
			descriptionLabel.text = AppStrings.ExposureNotificationSetting.authorizationRequiredENSettingDescription
			actionButton.setTitle(AppStrings.ExposureNotificationSetting.authorizationButtonTitle, for: .normal)
			iconImageView2.isHidden = true
		}
	}

	func configure(for state: ENStateHandler.State, delegate: ActionTableViewCellDelegate) {
		self.delegate = delegate
		self.state = state
		configure(for: state)
	}

	private func images(for state: ENStateHandler.State) -> (UIImage?, UIImage?) {
		switch state {
		case .enabled, .disabled:
			return (nil, nil)
		case .bluetoothOff:
			return (UIImage(named: "Icons_Bluetooth"), nil)
		case .restricted, .notAuthorized, .unknown:
			return (UIImage(named: "Icons_iOS_Settings"), nil)
		}
	}
}
