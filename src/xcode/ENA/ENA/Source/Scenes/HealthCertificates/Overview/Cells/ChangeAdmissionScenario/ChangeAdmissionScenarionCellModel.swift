////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ChangeAdmissionScenarionCellModel: AddButtonAsTableViewCelling {
	
	// MARK: - Init

	init(
		changeAdmissionScenarioButtonLabel: String
	) {
		self.text = changeAdmissionScenarioButtonLabel
	}
	
	// MARK: - Internal

	let text: String

	var iconImagePublisher = CurrentValueSubject<UIImage?, Never>(UIImage(named: "Icons_admission_state"))
	var textColorPublisher = CurrentValueSubject<UIColor, Never>(.enaColor(for: .textPrimary1))
	var accessibilityTraitsPublisher = CurrentValueSubject<UIAccessibilityTraits, Never>([.button])
	var isCustomAccessoryViewHiddenPublisher = CurrentValueSubject<Bool, Never>(false)

}
