////
// 🦠 Corona-Warn-App
//

import UIKit

struct DiaryDayEmptyViewModel {

	// MARK: - Init

	init(entryType: DiaryEntryType) {
		switch entryType {
		case .contactPerson:
			image = UIImage(named: "Illu_Diary_ContactPerson_Empty")
			title = AppStrings.ContactDiary.Day.contactPersonsEmptyTitle
			description = AppStrings.ContactDiary.Day.contactPersonsEmptyDescription
		case .location:
			image = UIImage(named: "Illu_Diary_Location_Empty")
			title = AppStrings.ContactDiary.Day.locationsEmptyTitle
			description = AppStrings.ContactDiary.Day.locationsEmptyDescription
		}
	}

	// MARK: - Internal

	let image: UIImage?
	let title: String
	let description: String

}
