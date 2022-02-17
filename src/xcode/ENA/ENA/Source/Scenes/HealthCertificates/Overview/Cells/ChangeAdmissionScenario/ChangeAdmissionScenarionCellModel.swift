////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ChangeAdmissionScenarionCellModel: AddButtonAsTableViewCelling {
	
	// MARK: - Internal

	// to.do should be dynamic - EXPOSUREAPP-11876
	let text: String = "Regeln des Bundes"

	var iconImagePublisher = CurrentValueSubject<UIImage?, Never>(UIImage(named: "Icons_admission_state"))
	var textColorPublisher = CurrentValueSubject<UIColor, Never>(.enaColor(for: .textPrimary1))
	var accessibilityTraitsPublisher = CurrentValueSubject<UIAccessibilityTraits, Never>([.button])
	var isCustomAccessoryViewHiddenPublisher = CurrentValueSubject<Bool, Never>(false)

}
