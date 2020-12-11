//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import Combine

class DiaryAddAndEditEntryViewModel {

	// MARK: - Init

	init(
		mode: Mode,
		diaryService: DiaryService
	) {
		self.mode = mode
		self.diaryService = diaryService

		switch mode {
		case .add:
			self.textInput = ""
		case .edit(let entry):
			switch entry {
			case .location(let location):
				self.textInput = location.name
			case .contactPerson(let person):
				self.textInput = person.name
			}
		}
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	enum Mode {
		case add(DiaryDay, DiaryEntryType)
		case edit(DiaryEntry)
	}

	let mode: Mode
	let diaryService: DiaryService

	@Published private(set) var textInput: String

	var title: String {
		switch mode {
		case .add(_, let entryType):
			return titleText(from: entryType)
		case .edit(let entry):
			return titleText(from: entry.type)
		}
	}

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
