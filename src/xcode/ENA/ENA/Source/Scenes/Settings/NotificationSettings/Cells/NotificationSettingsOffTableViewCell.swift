//
// 🦠 Corona-Warn-App
//

import UIKit

class NotificationSettingsOffTableViewCell: UITableViewCell {
	@IBOutlet var descriptionLabel: ENALabel!
	@IBOutlet var stateLabel: ENALabel!

	func configure(viewModel: NotificationSettingsViewModel.SettingsOffItem) {
		descriptionLabel.text = viewModel.description
		stateLabel.text = viewModel.state

		isAccessibilityElement = true
		accessibilityLabel = descriptionLabel.text
		accessibilityTraits = .none

	}
}
