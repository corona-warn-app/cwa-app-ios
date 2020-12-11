//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct DiaryAddAndEditEntryViewModel {

	// MARK: - Init

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	var title: String {
		switch mode {
		case .add(_, let entryType):
			return titleText(from: entryType)
		case .edit(let entry):
			return titleText(from: entry.type)
		}
	}

	enum Mode {
		case add(DiaryDay, DiaryEntryType)
		case edit(DiaryEntry)
	}

	let mode: Mode
	let diaryService: DiaryService

	// MARK: - Private

	private func titleText(from type: DiaryEntryType) -> String {
		switch type {
		case .location:
			return AppStrings.ContactDiary.AddEditEntry.locationTitle
		case .contactPerson:
			return AppStrings.ContactDiary.AddEditEntry.personTitle
		}
	}

}
