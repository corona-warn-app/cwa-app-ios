////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ChangeAdmissionScenarionCellModel: AddButtonAsTableViewCelling {
	
	// MARK: - Init

	init(
		changeAdmissionScenarioButtonText: String
	) {
		self.text = changeAdmissionScenarioButtonText
	}
	
	// MARK: - Internal

	let text: String
	let accessibilityIdentifier: String? = nil

	var iconImagePublisher = CurrentValueSubject<UIImage?, Never>(UIImage(named: "Icons_admission_state"))
	var textColorPublisher = CurrentValueSubject<UIColor, Never>(.enaColor(for: .textPrimary1))
	var accessibilityTraitsPublisher = CurrentValueSubject<UIAccessibilityTraits, Never>([.button])
	var isCustomAccessoryViewHiddenPublisher = CurrentValueSubject<Bool, Never>(false)

}
