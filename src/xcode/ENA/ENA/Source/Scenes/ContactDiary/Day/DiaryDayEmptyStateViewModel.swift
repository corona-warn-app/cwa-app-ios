////
// 🦠 Corona-Warn-App
//

import UIKit

struct DiaryDayEmptyStateViewModel: EmptyStateViewModel {

	// MARK: - Init

	init(entryType: DiaryEntryType) {
		switch entryType {
		case .contactPerson:
			image = UIImage(named: "Illu_Diary_ContactPerson_Empty")
			title = AppStrings.ContactDiary.Day.contactPersonsEmptyTitle
			description = AppStrings.ContactDiary.Day.contactPersonsEmptyDescription
			imageDescription = AppStrings.ContactDiary.Day.contactPersonsEmptyImageDescription
		case .location:
			image = UIImage(named: "Illu_Diary_Location_Empty")
			title = AppStrings.ContactDiary.Day.locationsEmptyTitle
			description = AppStrings.ContactDiary.Day.locationsEmptyDescription
			imageDescription = AppStrings.ContactDiary.Day.locationsEmptyImageDescription
		}
	}

	// MARK: - Internal

	let image: UIImage?
	let title: String
	let description: String
	let imageDescription: String

}
