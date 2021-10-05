//
// 🦠 Corona-Warn-App
//

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

	// change toogle state with a double tap (voice over ON)
	override func accessibilityActivate() -> Bool {
		toggle(self)
		return true
	}
	
}
