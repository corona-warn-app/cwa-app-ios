////
// 🦠 Corona-Warn-App
//

import UIKit

struct DiaryDayEntryCellModel {

	// MARK: - Init

	init(entry: DiaryEntry) {
		switch entry {
		case .contactPerson(let contactPerson):
			image = contactPerson.isSelected ? UIImage(named: "Diary_Checkmark_Selected") : UIImage(named: "Diary_Checkmark_Unselected")
			text = contactPerson.name
		case .location(let location):
			image = location.isSelected ? UIImage(named: "Diary_Checkmark_Selected") : UIImage(named: "Diary_Checkmark_Unselected")
			text = location.name
		}

		if entry.isSelected {
			accessibilityTraits = [.button, .selected]
		} else {
			accessibilityTraits = [.button]
		}
	}

	// MARK: - Internal

	let image: UIImage?
	let text: String
	let accessibilityTraits: UIAccessibilityTraits
    
}
