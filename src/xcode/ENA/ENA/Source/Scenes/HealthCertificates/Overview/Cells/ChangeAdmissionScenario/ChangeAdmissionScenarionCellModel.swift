////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ChangeAdmissionScenarionCellModel: AddButtonAsTableViewCelling {
	
	// MARK: - Internal

	// to.do should be dynamic
	let text: String = "Regeln des Bundes"

	var iconImagePublisher = CurrentValueSubject<UIImage?, Never>(UIImage(named: "Icons_Admission_State"))
	var textColorPublisher = CurrentValueSubject<UIColor, Never>(.enaColor(for: .textPrimary1))
	var accessibilityTraitsPublisher = CurrentValueSubject<UIAccessibilityTraits, Never>([.button])

}
