////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class MissingPermissionsCellModel {

	// MARK: - Internal

	var textColorPublisher = CurrentValueSubject<UIColor, Never>(.enaColor(for: .textPrimary1))
	var isButtonEnabledPublisher = CurrentValueSubject<Bool, Never>(true)

	func setEnabled(_ enabled: Bool) {
		textColorPublisher.value = enabled ? .enaColor(for: .textPrimary1) : .enaColor(for: .textPrimary2)
		isButtonEnabledPublisher.value = enabled
	}
    
}
