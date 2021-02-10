//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

protocol ConfigurableENSettingCell: UITableViewCell {
	func configure(for state: ENStateHandler.State)
}

class ImageTableViewCell: UITableViewCell, ConfigurableENSettingCell {
	@IBOutlet var imageContainerView: UIImageView!

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
	
	override func layoutSubviews() {
		super.layoutSubviews()
		separatorInset.left = bounds.width
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
