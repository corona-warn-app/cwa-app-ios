////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class AddCheckinCellModel: AddButtonAsTableViewCelling {

	// MARK: - Internal

	let text: String = AppStrings.Checkins.Overview.scanButtonTitle
	let accessibilityIdentifier: String? = AccessibilityIdentifiers.Checkin.Overview.addButton

	var iconImagePublisher = CurrentValueSubject<UIImage?, Never>(UIImage(named: "Icons_qrScan"))
	var textColorPublisher = CurrentValueSubject<UIColor, Never>(.enaColor(for: .textPrimary1))
	var accessibilityTraitsPublisher = CurrentValueSubject<UIAccessibilityTraits, Never>([.button])
	var isCustomAccessoryViewHiddenPublisher = CurrentValueSubject<Bool, Never>(true)

	func setEnabled(_ enabled: Bool) {
		iconImagePublisher.value = enabled ? UIImage(named: "Icons_qrScan") : UIImage(named: "Icons_qrScan_Grey")
		textColorPublisher.value = enabled ? .enaColor(for: .textPrimary1) : .enaColor(for: .textPrimary2)
		accessibilityTraitsPublisher.value = enabled ? [.button] : [.button, .notEnabled]
	}
    
}
