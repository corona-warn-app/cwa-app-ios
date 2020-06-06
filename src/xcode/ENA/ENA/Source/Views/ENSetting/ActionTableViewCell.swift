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

protocol ActionCell: ConfigurableENSettingCell {
	func configure(for state: ENStateHandler.State, delegate: ActionTableViewCellDelegate)
}

protocol ActionTableViewCellDelegate: AnyObject {
	func performAction(action: SettingAction)
}

enum SettingAction {
	case enable(Bool)
	case askConsent
}

class ActionTableViewCell: UITableViewCell, ActionCell {
	@IBOutlet var actionTitleLabel: UILabel!
	@IBOutlet var actionSwitch: ENASwitch!
	@IBOutlet var detailLabel: UILabel!

	weak var delegate: ActionTableViewCellDelegate?
	private var askForConsent = false

	@IBAction func switchValueDidChange(_: Any) {
		if askForConsent {
			delegate?.performAction(action: .askConsent)
		}
		delegate?.performAction(action: .enable(self.actionSwitch.isOn))
	}

	func turnSwitch(to on: Bool) {
		actionSwitch.setOn(on, animated: true)
	}

	func configure(for state: ENStateHandler.State) {
		askForConsent = false
		actionTitleLabel.text = AppStrings.ExposureNotificationSetting.enableTracing
		detailLabel.text = AppStrings.ExposureNotificationSetting.limitedTracing
		turnSwitch(to: state == .enabled)

		switch state {
		case .enabled, .disabled:
			detailLabel.isHidden = true
			actionSwitch.isHidden = false
		case .bluetoothOff, .internetOff:
			detailLabel.isHidden = false
			actionSwitch.isHidden = true
		case .restricted, .notAuthorized:
			detailLabel.isHidden = false
			actionSwitch.isHidden = true
			detailLabel.text = AppStrings.ExposureNotificationSetting.deactivatedTracing
		case .unknown:
			askForConsent = true
			detailLabel.isHidden = true
			actionSwitch.isHidden = false
		}
	}

	func configure(
		for state: ENStateHandler.State,
		delegate: ActionTableViewCellDelegate
	) {
		self.delegate = delegate
		configure(for: state)
	}
}
