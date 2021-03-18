//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ActionDetailTableViewCell: UITableViewCell {

	private var iconImageView: UIImageView!
	private var actionTitleLabel: ENALabel!
	private var descriptionLabel: ENALabel!
	private var actionButton: ENAButton!

	weak var delegate: ActionTableViewCellDelegate?
	var state: ENStateHandler.State?
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		// self
		selectionStyle = .none
		backgroundColor = .enaColor(for: .background)
		//
		let backgroundView = UIView()
		backgroundView.backgroundColor = .enaColor(for: .separator)
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.layer.cornerRadius = 16
		contentView.addSubview(backgroundView)
		// iconImageView
		iconImageView = UIImageView()
		iconImageView.contentMode = .scaleAspectFit
		iconImageView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.addSubview(iconImageView)
		// actionTitleLabel
		actionTitleLabel = ENALabel()
		actionTitleLabel.style = .title2
		actionTitleLabel.lineBreakMode = .byWordWrapping
		actionTitleLabel.numberOfLines = 0
		actionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.addSubview(actionTitleLabel)
		// descriptionLabel
		descriptionLabel = ENALabel()
		descriptionLabel.style = .body
		descriptionLabel.numberOfLines = 0
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.addSubview(descriptionLabel)
		// actionButton
		actionButton = ENAButton()
		actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
		actionButton.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.addSubview(actionButton)
		// activate constrinats
		NSLayoutConstraint.activate([
			// backgroundView
			backgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			backgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			backgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
			backgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			// iconView
			iconImageView.leadingAnchor.constraint(greaterThanOrEqualTo: backgroundView.leadingAnchor, constant: 16),
			iconImageView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
			iconImageView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 16),
			iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: backgroundView.bottomAnchor, constant: -16),
			iconImageView.widthAnchor.constraint(equalToConstant: 28),
			iconImageView.heightAnchor.constraint(equalToConstant: 28),
			// actionTitleLabel
			actionTitleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
			actionTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: iconImageView.leadingAnchor, constant: -8),
			actionTitleLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 16),
			actionTitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
			// descriptionLabel
			descriptionLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
			descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: backgroundView.trailingAnchor, constant: -16),
			descriptionLabel.topAnchor.constraint(equalTo: actionTitleLabel.bottomAnchor, constant: 8),
			descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
			// actionButton
			actionButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
			actionButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
			actionButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
			actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc
	private func actionButtonTapped() {
		if let state = self.state, state == .unknown {
			delegate?.performAction(action: .askConsent)
		} else {
			let url: URL?
			if state == .bluetoothOff {
				// this will open the os settings
				url = URL(string: "App-Prefs:root=General")
			} else {
				// this will open the app settings
				url = URL(string: UIApplication.openSettingsURLString)
			}
			if let url = url,
				UIApplication.shared.canOpenURL(url) {
				UIApplication.shared.open(url, completionHandler: nil)
			}
		}
	}

	func configure(for state: ENStateHandler.State) {
		iconImageView.image = images(for: state)
		actionButton.setTitle(AppStrings.ExposureNotificationSetting.detailActionButtonTitle, for: .normal)

		switch state {
		case .enabled, .disabled:
			return
		case .bluetoothOff:
			actionTitleLabel.text = AppStrings.ExposureNotificationSetting.activateBluetooth
			descriptionLabel.text = AppStrings.ExposureNotificationSetting.bluetoothDescription
		case .restricted:
			actionTitleLabel.text = AppStrings.ExposureNotificationSetting.activateParentalControlENSetting
			descriptionLabel.text = AppStrings.ExposureNotificationSetting.activateParentalControlENSettingDescription
		case .notAuthorized:
			if #available(iOS 13.7, *) {
				actionTitleLabel.text = AppStrings.ExposureNotificationSetting.activateOSENSetting
				descriptionLabel.text = AppStrings.ExposureNotificationSetting.activateOSENSettingDescription
			} else {
				actionTitleLabel.text = AppStrings.ExposureNotificationSetting.activateOldOSENSetting
				descriptionLabel.text = AppStrings.ExposureNotificationSetting.activateOldOSENSettingDescription
			}
		case .notActiveApp:
			if #available(iOS 13.7, *) {
				actionTitleLabel.text = AppStrings.ExposureNotificationSetting.activateAppOSENSetting
				descriptionLabel.text = AppStrings.ExposureNotificationSetting.activateAppOSENSettingDescription
			} else {
				actionTitleLabel.text = AppStrings.ExposureNotificationSetting.activateAppOSENSetting
				descriptionLabel.text = AppStrings.ExposureNotificationSetting.activateOldAppOSENSettingDescription
			}
		case .unknown:
			actionTitleLabel.text = AppStrings.ExposureNotificationSetting.authorizationRequiredENSetting
			descriptionLabel.text = AppStrings.ExposureNotificationSetting.authorizationRequiredENSettingDescription
			actionButton.setTitle(AppStrings.ExposureNotificationSetting.authorizationButtonTitle, for: .normal)
		}
	}

	func configure(for state: ENStateHandler.State, delegate: ActionTableViewCellDelegate) {
		self.delegate = delegate
		self.state = state
		configure(for: state)
	}

	private func images(for state: ENStateHandler.State) -> UIImage? {
		switch state {
		case .enabled, .disabled:
			return nil
		case .bluetoothOff:
			return UIImage(named: "Icons_Bluetooth")
		case .restricted, .notAuthorized, .unknown, .notActiveApp:
			return UIImage(named: "Icons_iOS_Settings")
		}
	}
}
