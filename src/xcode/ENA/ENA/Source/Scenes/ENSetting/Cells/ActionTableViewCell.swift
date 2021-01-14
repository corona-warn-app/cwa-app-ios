//
// 🦠 Corona-Warn-App
//

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
	@IBOutlet var switchContainerView: UIView!

	weak var delegate: ActionTableViewCellDelegate?
	private var askForConsent = false

	@IBAction func switchValueDidChange(_: Any) {
		if askForConsent {
			delegate?.performAction(action: .askConsent)
		} else {
			delegate?.performAction(action: .enable(self.actionSwitch.isOn))
		}
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
			switchContainerView.isHidden = false
		case .bluetoothOff:
			detailLabel.isHidden = false
			switchContainerView.isHidden = true
		case .restricted, .notAuthorized, .notActiveApp:
			detailLabel.isHidden = false
			switchContainerView.isHidden = true
			detailLabel.text = AppStrings.ExposureNotificationSetting.deactivatedTracing
		case .unknown:
			askForConsent = true
			detailLabel.isHidden = true
			switchContainerView.isHidden = false
		}

		setupAccessibility()
	}

	func configure(
		for state: ENStateHandler.State,
		delegate: ActionTableViewCellDelegate
	) {
		self.delegate = delegate
		configure(for: state)
	}

	@objc
	func toggle(_ sender: Any) {
		actionSwitch.isOn.toggle()
		switchValueDidChange(self)
		setupAccessibility()
	}

	private func setupAccessibility() {
		accessibilityIdentifier = AccessibilityIdentifiers.ExposureNotificationSetting.enableTracing

		isAccessibilityElement = true
		accessibilityTraits = [.button]

		accessibilityCustomActions?.removeAll()

		let actionName = actionSwitch.isOn ? AppStrings.Settings.statusDisable : AppStrings.Settings.statusEnable
		accessibilityCustomActions = [
			UIAccessibilityCustomAction(name: actionName, target: self, selector: #selector(toggle(_:)))
		]

		accessibilityLabel = AppStrings.ExposureNotificationSetting.enableTracing
		if switchContainerView.isHidden {
			accessibilityLabel = AppStrings.ExposureNotificationSetting.enableTracing
		} else {
			if actionSwitch.isOn {
				accessibilityValue = AppStrings.Settings.notificationStatusActive
			} else {
				accessibilityValue = AppStrings.Settings.notificationStatusInactive
			}
		}
	}

	override func accessibilityActivate() -> Bool {
		toggle(self)
		return true
	}
}
