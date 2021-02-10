//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

protocol ConfigurableENSettingCell: UITableViewCell {
	func configure(for state: ENStateHandler.State)
}

class ImageTableViewCell: UITableViewCell, ConfigurableENSettingCell {
	
	private var imageContainerView: UIImageView!

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
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		// self
		selectionStyle = .none
		contentView.backgroundColor = .enaColor(for: .background)
		// imageContainerView
		imageContainerView = UIImageView()
		imageContainerView.contentMode = .scaleAspectFit
		imageContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(imageContainerView)
		// activate constrinats
		NSLayoutConstraint.activate([
			// imageContainerView
			imageContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			imageContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			imageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
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
		case .disabled, .restricted, .notAuthorized, .unknown, .notActiveApp:
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
