//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class AddAntigenTestProfileCellModel: AddButtonAsTableViewCelling {

	// MARK: - Internal

	let text: String = AppStrings.AntigenProfile.Overview.addButtonTitle
	var accessibilityIdentifier: String? = AccessibilityIdentifiers.AntigenProfile.Overview.addButton

	var iconImagePublisher = CurrentValueSubject<UIImage?, Never>(UIImage(named: "Icon_Add"))
	var textColorPublisher = CurrentValueSubject<UIColor, Never>(.enaColor(for: .textPrimary1))
	var accessibilityTraitsPublisher = CurrentValueSubject<UIAccessibilityTraits, Never>([.button])
	var isCustomAccessoryViewHiddenPublisher = CurrentValueSubject<Bool, Never>(true)
	
	func setEnabled(_ enabled: Bool) {
		iconImagePublisher.value = enabled ? UIImage(named: "Icon_Add") : UIImage(named: "Icon_Add_Grey")
		textColorPublisher.value = enabled ? .enaColor(for: .textPrimary1) : .enaColor(for: .textPrimary2)
		accessibilityTraitsPublisher.value = enabled ? [.button] : [.button, .notEnabled]
	}
	
}
