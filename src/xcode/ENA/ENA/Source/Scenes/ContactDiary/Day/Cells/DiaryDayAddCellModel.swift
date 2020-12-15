////
// 🦠 Corona-Warn-App
//

import UIKit

struct DiaryDayAddCellModel {

	// MARK: - Init

	init(entryType: DiaryEntryType) {
		switch entryType {
		case .contactPerson:
			text = AppStrings.ContactDiary.Day.addContactPerson
		case .location:
			text = AppStrings.ContactDiary.Day.addLocation
		}

		accessibilityTraits = [.button]
	}

	// MARK: - Internal

	let text: String
	let accessibilityTraits: UIAccessibilityTraits
    
}
