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

import UIKit

class NotificationSettingsOnTableViewCell: UITableViewCell {
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var toggleSwitch: UISwitch!

	var viewModel: NotificationSettingsViewModel.SettingsOnItem?

	@IBAction func switchToggled(_: Any) {
		viewModel?.state = toggleSwitch.isOn
	}

	func configure() {
		guard let viewModel = viewModel else { return }

		descriptionLabel.text = viewModel.description
		toggleSwitch.isOn = viewModel.state

		setupAccessibility()
	}

	@objc
	func toggle(_ sender: Any) {
		toggleSwitch.isOn.toggle()
		setupAccessibility()
	}

	private func setupAccessibility() {
		guard let viewModel = viewModel else { return }
		print(viewModel)
		accessibilityIdentifier = viewModel.accessibilityIdentifier

		isAccessibilityElement = true
		accessibilityTraits = [.button]

		accessibilityCustomActions?.removeAll()

		let actionName = toggleSwitch.isOn ? AppStrings.Settings.statusDisable : AppStrings.Settings.statusEnable
		accessibilityCustomActions = [
			UIAccessibilityCustomAction(name: actionName, target: self, selector: #selector(toggle(_:)))
		]

		accessibilityLabel = viewModel.description
		if toggleSwitch.isOn {
			accessibilityValue = AppStrings.Settings.notificationStatusActive
		} else {
			accessibilityValue = AppStrings.Settings.notificationStatusInactive
		}
	}

}
