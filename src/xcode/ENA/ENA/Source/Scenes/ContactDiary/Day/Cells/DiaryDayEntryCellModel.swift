////
// 🦠 Corona-Warn-App
//

import UIKit

struct DiaryDayEntryCellModel {

	// MARK: - Init

	init(entry: DiaryEntry) {
		image = entry.isSelected ? UIImage(named: "Diary_Checkmark_Selected") : UIImage(named: "Diary_Checkmark_Unselected")
		text = entry.name

		entryType = entry.type
		parametersHidden = !entry.isSelected

		if entry.isSelected {
			accessibilityTraits = [.button, .selected]
		} else {
			accessibilityTraits = [.button]
		}
	}

	// MARK: - Internal

	let image: UIImage?
	let text: String

	let entryType: DiaryEntryType
	let parametersHidden: Bool

	let accessibilityTraits: UIAccessibilityTraits
    
}
