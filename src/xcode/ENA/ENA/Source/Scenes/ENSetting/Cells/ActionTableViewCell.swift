//
// 🦠 Corona-Warn-App
//

import UIKit

protocol ActionTableViewCellDelegate: AnyObject {
	func performAction(action: SettingAction)
}

enum SettingAction {
	case enable(Bool)
	case askConsent
}

class ActionTableViewCell: UITableViewCell {
	
	private var actionTitleLabel: ENALabel!
	private var actionSwitch: ENASwitch!
	private var detailLabel: ENALabel!
	private var layoutConstraints = [NSLayoutConstraint]()
	private var line: SeperatorLineLayer!
	private var askForConsent = false

	weak var delegate: ActionTableViewCellDelegate?
	
	@objc
	private func switchValueDidChange() {
		if askForConsent {
			delegate?.performAction(action: .askConsent)
		} else {
			delegate?.performAction(action: .enable(actionSwitch.isOn))
		}
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		// self
		selectionStyle = .none
		contentView.backgroundColor = .enaColor(for: .background)
		// actionTitleLabel
		actionTitleLabel = ENALabel()
		actionTitleLabel.style = .body
		actionTitleLabel.textColor = .enaColor(for: .textPrimary1)
		actionTitleLabel.numberOfLines = 0
		actionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(actionTitleLabel)
		// detailLabel
		detailLabel = ENALabel()
		detailLabel.style = .body
		detailLabel.textColor = .enaColor(for: .textPrimary2)
		detailLabel.numberOfLines = 0
		detailLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(detailLabel)
		// actionSwitch
		actionSwitch = ENASwitch()
		actionSwitch.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
		actionSwitch.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(actionSwitch)
		// line
		line = SeperatorLineLayer()
		contentView.layer.insertSublayer(line, at: 0)
		// activate constraints
		NSLayoutConstraint.activate([
			// actionTitleLabel
			actionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			actionTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
			actionTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			actionTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
			// detailLabel
			detailLabel.leadingAnchor.constraint(equalTo: actionTitleLabel.trailingAnchor, constant: 8),
			detailLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
			// actionSwitch
			actionSwitch.leadingAnchor.constraint(greaterThanOrEqualTo: actionTitleLabel.trailingAnchor, constant: 8),
			actionSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			actionSwitch.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10),
			actionSwitch.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
			actionSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let path = UIBezierPath()
		path.move(to: CGPoint(x: 0, y: 0))
		path.addLine(to: CGPoint(x: contentView.bounds.width, y: 0))
		let y = contentView.bounds.height - line.lineWidth / 2
		path.move(to: CGPoint(x: 0, y: y))
		path.addLine(to: CGPoint(x: contentView.bounds.width, y: y))
		line.path = path.cgPath
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
		case .bluetoothOff:
			detailLabel.isHidden = false
			actionSwitch.isHidden = true
		case .restricted, .notAuthorized, .notActiveApp:
			detailLabel.isHidden = false
			actionSwitch.isHidden = true
			detailLabel.text = AppStrings.ExposureNotificationSetting.deactivatedTracing
		case .unknown:
			askForConsent = true
			detailLabel.isHidden = true
			actionSwitch.isHidden = false
		}
		
		setupAccessibility()
		setupConstraints()
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
		switchValueDidChange()
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
		if actionSwitch.isHidden {
			accessibilityLabel = AppStrings.ExposureNotificationSetting.enableTracing
		} else {
			if actionSwitch.isOn {
				accessibilityValue = AppStrings.Settings.notificationStatusActive
			} else {
				accessibilityValue = AppStrings.Settings.notificationStatusInactive
			}
		}
	}
	
	private func setupConstraints() {
		// clear
		NSLayoutConstraint.deactivate(layoutConstraints)
		layoutConstraints.removeAll()
		// setup
		if !detailLabel.isHidden && !actionSwitch.isHidden {
			layoutConstraints.append(contentsOf: [
				// detailLabel
				detailLabel.trailingAnchor.constraint(equalTo: actionSwitch.leadingAnchor, constant: -8)
			])
		} else if !detailLabel.isHidden {
			layoutConstraints.append(contentsOf: [
				// detailLabel
				detailLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
			])
		}
		// activate constrints
		NSLayoutConstraint.activate(layoutConstraints)
	}

	override func accessibilityActivate() -> Bool {
		toggle(self)
		return true
	}
}
